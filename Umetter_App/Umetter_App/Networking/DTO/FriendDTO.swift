import Foundation

struct FriendshipResponse: Decodable {
    let id: String
    let requesterId: String
    let addresseeId: String
    let status: String
    let createdAt: String
    let updatedAt: String
}

struct FriendListResponse: Decodable {
    let friendships: [FriendshipResponse]
}

struct FriendRequestBody: Encodable {
    let addresseeId: String
}

struct FriendRespondBody: Encodable {
    let status: String
}
