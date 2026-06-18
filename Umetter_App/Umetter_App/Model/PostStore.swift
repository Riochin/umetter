import Foundation
import Combine

@MainActor
class PostStore: ObservableObject {
    static let shared = PostStore()
    
    @Published var posts: [PostModel] = []
    
    private init() {
        loadMockData()
    }
    
    func loadMockData() {
        posts = [
            PostModel(
                id: UUID(),
                userId: UUID(),
                userName: "名無しさん",
                createdAt: Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date(),
                content: "今日の2限の〇〇先生の授業、休講になったらしい！サイトにも出てる。",
                tags: ["#休講情報", "#学芸学部"],
                imageUrl: nil,
                likesCount: 12,
                isLiked: false,
                isSaved: false
            ),
            PostModel(
                id: UUID(),
                userId: UUID(),
                userName: "匿名希望",
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                content: "学食の新メニュー、美味しかったですよ！🍜",
                tags: ["#学食", "#ランチ"],
                imageUrl: nil,
                likesCount: 8,
                isLiked: false,
                isSaved: false
            )
        ]
    }
    
    func addPost(_ post: PostModel) {
        posts.insert(post, at: 0)
    }
    
    func toggleLike(for postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isLiked.toggle()
            posts[index].likesCount += posts[index].isLiked ? 1 : -1
        }
    }
    
    func toggleSave(for postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isSaved.toggle()
        }
    }
}
