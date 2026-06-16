import SwiftUI

// MARK: - Friend Model
struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let department: String
    var isFriend: Bool
    let iconColor: Color
}
