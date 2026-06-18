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
    
    // PostStoreとUserStoreを監視するための仕組み
    private var cancellables = Set<AnyCancellable>()
    
    @Published var allPosts: [PostModel] = []

    init() {
        // PostStoreの変更を検知
        PostStore.shared.$posts
            .assign(to: &$allPosts)
        
        // UserStoreの変更を検知して自分自身のプロパティを更新する
        UserStore.shared.$profile
            .assign(to: &$userProfile)
        
        loadMockFriends()
    }
    
    private func loadMockFriends() {
        friends = []
    }

    var myPosts: [PostModel] {
        allPosts.filter { $0.userId == userProfile.id }
    }
    
    var likedPosts: [PostModel] {
        allPosts.filter { $0.isLiked }
    }
    
    var savedPosts: [PostModel] {
        allPosts.filter { $0.isSaved }
    }

    var friendsCount: Int {
        friends.filter { $0.isFriend }.count
    }
    var postsCount: Int {
        myPosts.count
    }
    
    func switchTab(to index: Int) {
        withAnimation {
            selectedTab = index
        }
    }
    
    func toggleFriendStatus(for friendId: UUID) {
        if let index = friends.firstIndex(where: { $0.id == friendId }) {
            friends[index].isFriend.toggle()
            let friend = friends[index]
            displayToast(message: friend.isFriend ? "\(friend.name) さんを友達に追加しました" : "\(friend.name) さんを友達から解除しました")
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
    
    private func displayToast(message: String) {
        toastMessage = message
        withAnimation(.easeOut(duration: 0.3)) {
            showToast = true
        }
        
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.showToast = false
                }
            }
        }
    }
}
