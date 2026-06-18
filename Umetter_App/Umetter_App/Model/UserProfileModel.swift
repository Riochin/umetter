import SwiftUI

struct UserProfile {
    let id: UUID
    var backendId: String
    var email: String
    var name: String
    var department: String
    var enrollmentYear: String
    var admissionYear: Int
    var bio: String
    var iconColor: Color
    var timetableVisibility: String
    var role: String

    static let anonymous = UserProfile(
        id: UUID(),
        backendId: "",
        email: "",
        name: "あなた（匿名）",
        department: "",
        enrollmentYear: "",
        admissionYear: 0,
        bio: "",
        iconColor: .borderColor,
        timetableVisibility: "private",
        role: "student"
    )

    init(from user: UserResponse) {
        self.id = UUID()
        self.backendId = user.id
        self.email = user.email
        self.name = user.displayName.isEmpty ? "匿名" : user.displayName
        self.department = user.department
        self.admissionYear = user.admissionYear
        self.enrollmentYear = "\(user.admissionYear)年"
        self.bio = ""
        self.iconColor = .borderColor
        self.timetableVisibility = user.timetableVisibility
        self.role = user.role
    }

    init(id: UUID, backendId: String, email: String, name: String, department: String,
         enrollmentYear: String, admissionYear: Int, bio: String, iconColor: Color,
         timetableVisibility: String, role: String) {
        self.id = id
        self.backendId = backendId
        self.email = email
        self.name = name
        self.department = department
        self.enrollmentYear = enrollmentYear
        self.admissionYear = admissionYear
        self.bio = bio
        self.iconColor = iconColor
        self.timetableVisibility = timetableVisibility
        self.role = role
    }
}
