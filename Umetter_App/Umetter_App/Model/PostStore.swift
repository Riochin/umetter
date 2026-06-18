import Foundation
import Combine

@MainActor
class PostStore: ObservableObject {
    static let shared = PostStore()

    @Published var posts: [PostModel] = []
    @Published var isLoading = false
    @Published var error: APIError? = nil

    private init() {}

    func loadFromAPI(category: String = "") async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let path = category.isEmpty ? "/posts" : "/posts?category=\(category)"
            let response: PostListResponse = try await APIClient.shared.request(APIEndpoint.url(path))
            posts = response.posts.map { PostModel(from: $0) }
        } catch let e as APIError {
            error = e
        } catch {
            self.error = .serverError
        }
    }

    func createPost(body: String, category: String) async throws {
        let req = CreatePostRequest(body: body, category: category, attachmentUrl: nil)
        let resp: CreatePostResponse = try await APIClient.shared.request(
            APIEndpoint.url("/posts"), method: "POST", body: req
        )
        let now = ISO8601DateFormatter().string(from: Date())
        let optimistic = PostModel(
            id: resp.id,
            authorId: UserStore.shared.currentUser?.id ?? "",
            createdAt: now,
            body: body,
            category: category,
            attachmentUrl: nil,
            isPinned: false,
            likesCount: 0,
            isLiked: false,
            isSaved: false
        )
        posts.insert(optimistic, at: 0)
    }

    func toggleLike(for postId: String) {
        if let i = posts.firstIndex(where: { $0.id == postId }) {
            posts[i].isLiked.toggle()
            posts[i].likesCount += posts[i].isLiked ? 1 : -1
        }
    }

    func toggleSave(for postId: String) {
        if let i = posts.firstIndex(where: { $0.id == postId }) {
            posts[i].isSaved.toggle()
        }
    }
}
