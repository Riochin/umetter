import SwiftUI
import Combine

@MainActor
class UserStore: ObservableObject {
    static let shared = UserStore()
    
    @Published var profile: UserProfile
    
    private init() {
        // 初期状態：名前は「あなた（匿名）」、IDを固定で生成
        self.profile = UserProfile(
            id: UUID(),
            name: "あなた（匿名）",
            department: "",
            enrollmentYear: "",
            bio: "",
            iconColor: Color.borderColor
        )
    }
    
    func updateProfile(name: String, department: String, enrollmentYear: String, bio: String, iconColor: Color) {
        profile.name = name
        profile.department = department
        profile.enrollmentYear = enrollmentYear
        profile.bio = bio
        profile.iconColor = iconColor
    }
}
