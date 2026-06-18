import Foundation
import Combine

class NotionViewModel: ObservableObject {
    @Published var selectedTab: NotificationTab = .all
    @Published var allNotifications: [NotionItemModel] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // ピン投稿 → お知らせ通知
        PostStore.shared.$posts
            .combineLatest(FriendStore.shared.$friendships)
            .receive(on: RunLoop.main)
            .sink { [weak self] posts, friendships in
                self?.recompute(posts: posts, friendships: friendships)
            }
            .store(in: &cancellables)
    }

    var filteredNotifications: [NotionItemModel] {
        switch selectedTab {
        case .all:          return allNotifications
        case .classInfo:    return allNotifications.filter { $0.type == .classAlarm }
        case .cancellation: return allNotifications.filter { $0.type == .cancellation }
        }
    }

    private func recompute(posts: [PostModel], friendships: [FriendshipResponse]) {
        var items: [NotionItemModel] = []

        // ピン投稿 → 休講・お知らせ扱い
        for post in posts where post.isPinned {
            items.append(NotionItemModel(
                title: "お知らせ",
                message: post.body,
                createdAt: Date(),
                type: .cancellation,
                isPast: false
            ))
        }

        // 自分宛ての pending 友達申請 → 通知
        let myId = UserStore.shared.currentUser?.id ?? ""
        for fs in friendships where fs.status == "pending" && fs.addresseeId == myId {
            items.append(NotionItemModel(
                title: "友達申請",
                message: "ユーザー \(fs.requesterId.prefix(8)) さんから友達申請が届いています",
                createdAt: Date(),
                type: .classAlarm,
                isPast: false
            ))
        }

        allNotifications = items
    }
}
