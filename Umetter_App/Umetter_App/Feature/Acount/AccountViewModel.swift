import SwiftUI
import Combine

@MainActor
class AccountViewModel: ObservableObject {

    @Published var selectedTab = 0
    

    @Published var showToast = false
    @Published var toastMessage = ""
    private var toastTask: Task<Void, Never>? = nil
    
    
    @Published var userProfile = UserProfile(
        name: "",
        department: "",
        enrollmentYear: "",
        bio: "",
        iconColor: Color.borderColor
    )
    
  
    @Published var showingEditProfile = false
    

    @Published var friends: [Friend] = []
    @Published var myPosts: [AccountPost] = []
    @Published var likedPosts: [AccountPost] = []
    @Published var savedPosts: [AccountPost] = []
    

    var friendsCount: Int {
        friends.filter { $0.isFriend }.count
    }
    var postsCount: Int {
        myPosts.count
    }
    
    // MARK: - Actions
    
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
    

    func saveProfile(name: String, department: String, enrollmentYear: String, bio: String, iconColor: Color) {
        userProfile.name = name
        userProfile.department = department
        userProfile.enrollmentYear = enrollmentYear
        userProfile.bio = bio
        userProfile.iconColor = iconColor
        
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
