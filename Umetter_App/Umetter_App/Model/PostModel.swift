import Foundation

// 投稿データの設計図
struct PostModel: Identifiable {
    let id: UUID
    let userName: String
    let timeAgo: String
    let content: String
    let tags: [String]
    let imageUrl: String?
    
    var likesCount: Int
    var isLiked: Bool
    var isSaved: Bool
}
