import Foundation

struct UserResponse: Decodable {
    let id: String
    let email: String
    let department: String
    let admissionYear: Int
    let displayName: String
    let role: String
    let timetableVisibility: String
}
