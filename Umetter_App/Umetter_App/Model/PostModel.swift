import Foundation

struct PostModel: Identifiable {
    let id: UUID
    let userName: String
    let createdAt: Date
    let content: String
    let tags: [String]
    let imageUrl: String?
    
    var likesCount: Int
    var isLiked: Bool
    var isSaved: Bool
    
    func timeAgo(from now: Date) -> String {
        let seconds = Int(now.timeIntervalSince(createdAt))
        
        if seconds < 60 {
            return "今"
        } else if seconds < 3600 {
            return "\(seconds / 60)分前"
        } else if seconds < 86400 {
            return "\(seconds / 3600)時間前"
        } else {
            return "\(seconds / 86400)日前"
        }
    }
}
