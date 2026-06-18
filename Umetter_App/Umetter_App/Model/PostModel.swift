import Foundation

struct PostModel: Identifiable {
    let id: String
    let authorId: String?
    let createdAt: String
    let body: String
    let category: String
    let attachmentUrl: String?
    let isPinned: Bool

    var likesCount: Int
    var isLiked: Bool
    var isSaved: Bool

    var tags: [String] { category.isEmpty ? [] : [category] }

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func timeAgo(from now: Date) -> String {
        let date = Self.iso8601Formatter.date(from: createdAt) ?? Date()
        let seconds = Int(now.timeIntervalSince(date))
        if seconds < 60 { return "今" }
        if seconds < 3600 { return "\(seconds / 60)分前" }
        if seconds < 86400 { return "\(seconds / 3600)時間前" }
        return "\(seconds / 86400)日前"
    }

    init(from dto: PostResponse) {
        self.id = dto.id
        self.authorId = dto.authorId ?? ""
        self.createdAt = dto.createdAt
        self.body = dto.body
        self.category = dto.category
        self.attachmentUrl = dto.attachmentUrl.flatMap { $0.isEmpty ? nil : $0 }
        self.isPinned = dto.isPinned
        self.likesCount = 0
        self.isLiked = false
        self.isSaved = false
    }

    init(id: String, authorId: String, createdAt: String, body: String, category: String,
         attachmentUrl: String?, isPinned: Bool, likesCount: Int, isLiked: Bool, isSaved: Bool) {
        self.id = id
        self.authorId = authorId
        self.createdAt = createdAt
        self.body = body
        self.category = category
        self.attachmentUrl = attachmentUrl
        self.isPinned = isPinned
        self.likesCount = likesCount
        self.isLiked = isLiked
        self.isSaved = isSaved
    }
}
