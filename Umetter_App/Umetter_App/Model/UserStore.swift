import SwiftUI
import Combine

@MainActor
class UserStore: ObservableObject {
    static let shared = UserStore()

    @Published var currentUser: UserResponse? = nil
    @Published var profile: UserProfile = .anonymous

    private init() {}

    func login(user: UserResponse, token: String) {
        KeychainHelper.save(token)
        currentUser = user
        profile = UserProfile(from: user)
    }

    func logout() {
        KeychainHelper.delete()
        currentUser = nil
        profile = .anonymous
    }

    func refreshMe() async throws {
        let user: UserResponse = try await APIClient.shared.request(APIEndpoint.url("/me"))
        currentUser = user
        profile = UserProfile(from: user)
    }

    func updateProfile(name: String, department: String, enrollmentYear: String, bio: String, iconColor: Color) {
        profile.name = name
        profile.department = department
        profile.enrollmentYear = enrollmentYear
        profile.bio = bio
        profile.iconColor = iconColor
    }

    func updateVisibility(_ visibility: String) async throws {
        struct Body: Encodable { let timetableVisibility: String }
        let updated: UserResponse = try await APIClient.shared.request(
            APIEndpoint.url("/me/visibility"),
            method: "PATCH",
            body: Body(timetableVisibility: visibility)
        )
        currentUser = updated
        profile.timetableVisibility = updated.timetableVisibility
    }
}
