import SwiftUI

// MARK: - Account Post Model
struct AccountPost: Identifiable {
    let id = UUID()
    let author: String
    let timeAgo: String
    let content: String
    let tags: [String]
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
}
