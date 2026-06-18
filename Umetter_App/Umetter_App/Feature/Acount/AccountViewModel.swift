import SwiftUI
import Combine

@MainActor
class AccountViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var showToast = false
    @Published var toastMessage = ""
    private var toastTask: Task<Void, Never>? = nil

    @Published var userProfile: UserProfile = UserStore.shared.profile
    @Published var showingEditProfile = false
    @Published var friends: [Friend] = []

    private var cancellables = Set<AnyCancellable>()
    @Published var allPosts: [PostModel] = []

    init() {
        PostStore.shared.$posts
            .assign(to: &$allPosts)

        UserStore.shared.$profile
            .assign(to: &$userProfile)

        FriendStore.shared.$friendships
            .map { $0.map { Friend(from: $0) } }
            .assign(to: &$friends)
    }

    func loadFriends() async {
        await FriendStore.shared.loadFromAPI()
    }

    var myPosts: [PostModel] {
        let myId = UserStore.shared.currentUser?.id ?? ""
        return allPosts.filter { $0.authorId == myId }
    }

    var likedPosts: [PostModel]  { allPosts.filter { $0.isLiked } }
    var savedPosts: [PostModel]  { allPosts.filter { $0.isSaved } }

    var friendsCount: Int { friends.filter { $0.isApproved }.count }
    var postsCount: Int   { myPosts.count }

    func switchTab(to index: Int) {
        withAnimation { selectedTab = index }
    }

    func respondToFriend(friendshipId: String, approved: Bool) {
        Task {
            do {
                try await FriendStore.shared.respond(
                    friendshipId: friendshipId,
                    status: approved ? "approved" : "rejected"
                )
                displayToast(message: approved ? "友達申請を承認しました" : "友達申請を拒否しました")
            } catch let error as APIError {
                displayToast(message: error.localizedDescription ?? "エラーが発生しました")
            }
        }
    }

    func toggleLike(for post: PostModel) {
        PostStore.shared.toggleLike(for: post.id)
    }

    func toggleSave(for post: PostModel) {
        PostStore.shared.toggleSave(for: post.id)
    }

    func saveProfile(name: String, department: String, enrollmentYear: String, bio: String, iconColor: Color) {
        UserStore.shared.updateProfile(
            name: name,
            department: department,
            enrollmentYear: enrollmentYear,
            bio: bio,
            iconColor: iconColor
        )
        displayToast(message: "プロフィールを更新しました")
    }

    func saveVisibility(_ visibility: String) {
        Task {
            do {
                try await UserStore.shared.updateVisibility(visibility)
                displayToast(message: "公開設定を更新しました")
            } catch let error as APIError {
                displayToast(message: error.localizedDescription ?? "エラーが発生しました")
            }
        }
    }

    private func displayToast(message: String) {
        toastMessage = message
        withAnimation(.easeOut(duration: 0.3)) { showToast = true }
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled {
                withAnimation(.easeIn(duration: 0.3)) { self.showToast = false }
            }
        }
    }
}
