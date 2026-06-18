import SwiftUI

struct Friend: Identifiable {
    let id: UUID
    let friendshipId: String
    let requesterId: String
    let addresseeId: String
    let name: String
    let department: String
    var status: String
    let iconColor: Color

    var isApproved: Bool { status == "approved" }
    var isPending: Bool  { status == "pending" }

    init(from dto: FriendshipResponse) {
        self.id = UUID()
        self.friendshipId = dto.id
        self.requesterId = dto.requesterId
        self.addresseeId = dto.addresseeId
        self.status = dto.status
        self.name = "ユーザー \(dto.requesterId.prefix(8))"
        self.department = ""
        self.iconColor = .borderColor
    }
}
