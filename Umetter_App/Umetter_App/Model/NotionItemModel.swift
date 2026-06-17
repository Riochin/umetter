import Foundation
import SwiftUI

// 通知タブの種類
enum NotificationTab {
    case all
    case classInfo
    case cancellation
}

// 通知の種類
enum NotificationType {
    case cancellation
    case classAlarm
    case hashtag
    case like
    
    var iconName: String {
        switch self {
        case .cancellation: return "exclamationmark.triangle.fill"
        case .classAlarm: return "bell.fill"
        case .hashtag: return "number"
        case .like: return "heart.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .cancellation: return Color.orange
        case .classAlarm, .like:
            return Color(red: 139/255, green: 30/255, blue: 56/255)
        case .hashtag:
            return Color.blue
        }
    }
    
    var iconBackground: Color {
        switch self {
        case .cancellation:
            return Color(red: 255/255, green: 247/255, blue: 237/255)
        case .classAlarm, .like:
            return Color(red: 255/255, green: 241/255, blue: 242/255)
        case .hashtag:
            return Color(red: 239/255, green: 246/255, blue: 255/255)
        }
    }
}

struct NotionItemModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let createdAt: Date
    let type: NotificationType
    let isPast: Bool
    
    func timeAgo(now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(createdAt)))
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if seconds < 60 {
            return "たった今"
        } else if minutes <= 10 {
            return "\(minutes)分前"
        } else if minutes < 15 {
            return "10分前"
        } else if minutes < 20 {
            return "15分前"
        } else if minutes < 30 {
            return "20分前"
        } else if minutes < 40 {
            return "30分前"
        } else if minutes < 50 {
            return "40分前"
        } else if minutes < 60 {
            return "50分前"
        } else if hours < 24 {
            return "\(hours)時間前"
        } else {
            return "\(hours / 24)日前"
        }
    }
}
