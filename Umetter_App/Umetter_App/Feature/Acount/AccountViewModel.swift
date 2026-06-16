import SwiftUI
import Combine

@MainActor
class AccountViewModel: ObservableObject {
    // タブ状態
    @Published var selectedTab = 0
    
    // トースト通知状態
    @Published var showToast = false
    @Published var toastMessage = ""
    private var toastTask: Task<Void, Never>? = nil
    
    // 💡 修正: 友達の仮データを削除して空配列にしました
    @Published var friends: [Friend] = []
    
    @Published var myPosts: [AccountPost] = []
    
    @Published var likedPosts: [AccountPost] = [
        AccountPost(author: "名無しさん", timeAgo: "1日前", content: "明日の1限休講らしい！サイト確認してみて！", tags: ["#休講情報"], likes: 12, isLiked: true)
    ]
    
    @Published var savedPosts: [AccountPost] = [
        AccountPost(author: "名無しさん", timeAgo: "3日前", content: "お勧めの一般教養の授業教えてください🙏\nできればレポート少なめのやつで...", tags: ["#質問", "#履修登録"], likes: 3, isSaved: true)
    ]
    
    // 統計情報（計算プロパティ）
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
