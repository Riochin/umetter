import Foundation

struct ClassResponse: Decodable {
    let id: String
    let classCode: String
    let name: String
    let teacherName: String
    let dayOfWeek: Int
    let period: Int
    let room: String
    let term: String
    let semester: String
    let level: String
    let credits: Int
    let remarks: String
    let isCanceled: Bool
}

struct ClassListResponse: Decodable {
    let classes: [ClassResponse]
}
