import Foundation

struct TimetableEntryResponse: Decodable {
    let id: String
    let classId: String
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
    let memo: String
    let countPresent: Int
    let countAbsent: Int
    let countLate: Int
    let createdAt: String
}

struct TimetableListResponse: Decodable {
    let timetable: [TimetableEntryResponse]
}

struct CreateTimetableRequest: Encodable {
    let classId: String
    let memo: String
}

struct UpdateTimetableRequest: Encodable {
    let memo: String?
    let countPresent: Int?
    let countAbsent: Int?
    let countLate: Int?

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(memo, forKey: .memo)
        try container.encodeIfPresent(countPresent, forKey: .countPresent)
        try container.encodeIfPresent(countAbsent, forKey: .countAbsent)
        try container.encodeIfPresent(countLate, forKey: .countLate)
    }

    enum CodingKeys: String, CodingKey {
        case memo
        case countPresent = "count_present"
        case countAbsent  = "count_absent"
        case countLate    = "count_late"
    }
}
