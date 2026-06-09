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
    
    // データソース
    @Published var friends: [Friend] = [
        Friend(name: "津田 梅子", department: "学芸学部 英文学科", isFriend: true, iconColor: Color(hex: "E5E7EB")),
        Friend(name: "小平 花子", department: "学芸学部 情報科学科", isFriend: true, iconColor: Color(hex: "FCA5A5")),
        Friend(name: "千駄ヶ谷 桜", department: "総合政策学部", isFriend: true, iconColor: Color(hex: "93C5FD")),
        Friend(name: "国分寺 もも", department: "学芸学部 国際関係学科", isFriend: false, iconColor: Color(hex: "D8B4FE"))
    ]
    
    @Published var myPosts: [Post] = [
        Post(author: "あなた", timeAgo: "2時間前", content: "今日のランチはルネで食べました！美味しかった〜😋\n午後からの授業も頑張ります！", tags: ["#ランチ", "#学食"], likes: 5, isLiked: true)
    ]
    
    @Published var likedPosts: [Post] = [
        Post(author: "名無しさん", timeAgo: "1日前", content: "明日の1限休講らしい！サイト確認してみて！", tags: ["#休講情報"], likes: 12, isLiked: true)
    ]
    
    @Published var savedPosts: [Post] = [
        Post(author: "名無しさん", timeAgo: "3日前", content: "お勧めの一般教養の授業教えてください🙏\nできればレポート少なめのやつで...", tags: ["#質問", "#履修登録"], likes: 3, isSaved: true)
    ]
    
    // 統計情報（計算プロパティ）
    var friendsCount: Int {
        friends.filter { $0.isFriend }.count
    }
    var postsCount: Int {
        myPosts.count + 41 // モック値
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
        
        // 既存の非表示タスクをキャンセル（連続タップ対応）
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
