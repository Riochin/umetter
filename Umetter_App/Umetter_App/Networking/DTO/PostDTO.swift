import Foundation

struct PostResponse: Decodable {
    let id: String
    let authorId: String?
    let postType: Int
    let category: String
    let body: String
    let attachmentUrl: String?
    let isPinned: Bool
    let createdAt: String
}

struct PostListResponse: Decodable {
    let posts: [PostResponse]
}

struct CreatePostRequest: Encodable {
    let body: String
    let category: String
    let attachmentUrl: String?
}

struct CreatePostResponse: Decodable {
    let id: String
}
