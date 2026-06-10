import Foundation
import Combine
class NotionViewModel: ObservableObject {
    @Published var selectedTab: NotificationTab = .all
    @Published var allNotifications: [NotionItemModel] = []
    
    init() {
        loadMockData()
    }
    
    var filteredNotifications: [NotionItemModel] {
        switch selectedTab {
        case .all:
            return allNotifications
        case .classInfo:
            return allNotifications.filter { $0.type == .classAlarm }
        case .cancellation:
            return allNotifications.filter { $0.type == .cancellation }
        }
    }
    
    func addNotification(
        title: String,
        message: String,
        type: NotificationType
    ) {
        let newNotification = NotionItemModel(
            title: title,
            message: message,
            createdAt: Date(),
            type: type,
            isPast: false
        )
        
        allNotifications.insert(newNotification, at: 0)
    }
    
    private func loadMockData() {
        allNotifications = [
            NotionItemModel(
                title: "授業開始通知",
                message: "あと10分で授業が始まります。遅れないように教室【S105】に向かいましょう！",
                createdAt: Date(),
                type: .classAlarm,
                isPast: false
            ),
            
            NotionItemModel(
                title: "休講情報",
                message: "2限の「女性学概論」は休講です。",
                createdAt: Date(),
                type: .cancellation,
                isPast: false
            )
        ]
    }
}
