import Foundation
import Combine

@MainActor
class FriendStore: ObservableObject {
    static let shared = FriendStore()

    @Published var friendships: [FriendshipResponse] = []
    @Published var isLoading = false
    @Published var error: APIError? = nil

    private init() {}

    func loadFromAPI() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let response: FriendListResponse = try await APIClient.shared.request(
                APIEndpoint.url("/friends")
            )
            friendships = response.friendships
        } catch let e as APIError {
            error = e
        } catch {
            self.error = .serverError
        }
    }

    func sendRequest(addresseeId: String) async throws {
        struct Resp: Decodable { let id: String }
        let _: Resp = try await APIClient.shared.request(
            APIEndpoint.url("/friends/request"),
            method: "POST",
            body: FriendRequestBody(addresseeId: addresseeId)
        )
        await loadFromAPI()
    }

    func respond(friendshipId: String, status: String) async throws {
        struct Msg: Decodable { let message: String }
        let _: Msg = try await APIClient.shared.request(
            APIEndpoint.url("/friends/\(friendshipId)"),
            method: "PATCH",
            body: FriendRespondBody(status: status)
        )
        if let i = friendships.firstIndex(where: { $0.id == friendshipId }) {
            friendships[i] = FriendshipResponse(
                id: friendships[i].id,
                requesterId: friendships[i].requesterId,
                addresseeId: friendships[i].addresseeId,
                status: status,
                createdAt: friendships[i].createdAt,
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
        }
    }
}
