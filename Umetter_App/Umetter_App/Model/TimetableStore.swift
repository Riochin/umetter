import Foundation
import Combine

@MainActor
class TimetableStore: ObservableObject {
    static let shared = TimetableStore()

    @Published var entries: [TimetableEntryResponse] = []
    @Published var isLoading = false
    @Published var error: APIError? = nil

    private init() {}

    func loadFromAPI() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let response: TimetableListResponse = try await APIClient.shared.request(
                APIEndpoint.url("/timetables")
            )
            entries = response.timetable
        } catch let e as APIError {
            error = e
        } catch {
            self.error = .serverError
        }
    }

    func addEntry(classId: String, memo: String = "") async throws {
        let req = CreateTimetableRequest(classId: classId, memo: memo)
        let _: CreateTimetableResponse = try await APIClient.shared.request(
            APIEndpoint.url("/timetables"), method: "POST", body: req
        )
        await loadFromAPI()
    }

    func updateEntry(id: String, memo: String? = nil, countPresent: Int? = nil,
                     countAbsent: Int? = nil, countLate: Int? = nil) async throws {
        let req = UpdateTimetableRequest(memo: memo, countPresent: countPresent,
                                         countAbsent: countAbsent, countLate: countLate)
        struct Msg: Decodable { let message: String }
        let _: Msg = try await APIClient.shared.request(
            APIEndpoint.url("/timetables/\(id)"), method: "PATCH", body: req
        )
        if let i = entries.firstIndex(where: { $0.id == id }) {
            if let m = memo         { entries[i] = updatedEntry(entries[i], memo: m) }
            if let p = countPresent { entries[i] = updatedEntry(entries[i], countPresent: p) }
            if let a = countAbsent  { entries[i] = updatedEntry(entries[i], countAbsent: a) }
            if let l = countLate    { entries[i] = updatedEntry(entries[i], countLate: l) }
        }
    }

    // MARK: - Helpers

    static func termKey(term: String, year: String) -> String {
        let termStr: String
        switch term {
        case "T1": termStr = "1ターム"
        case "T2": termStr = "2ターム"
        case "T3": termStr = "3ターム"
        case "T4": termStr = "4ターム"
        default:   termStr = term
        }
        return "\(year)_\(termStr)"
    }

    static func dayString(from dayOfWeek: Int) -> String {
        switch dayOfWeek {
        case 0: return "日"
        case 1: return "月"
        case 2: return "火"
        case 3: return "水"
        case 4: return "木"
        case 5: return "金"
        case 6: return "土"
        default: return "月"
        }
    }

    private func updatedEntry(_ e: TimetableEntryResponse, memo: String? = nil,
                               countPresent: Int? = nil, countAbsent: Int? = nil,
                               countLate: Int? = nil) -> TimetableEntryResponse {
        TimetableEntryResponse(
            id: e.id, classId: e.classId, classCode: e.classCode, name: e.name,
            teacherName: e.teacherName, dayOfWeek: e.dayOfWeek, period: e.period,
            room: e.room, term: e.term, semester: e.semester, level: e.level,
            credits: e.credits, remarks: e.remarks, isCanceled: e.isCanceled,
            memo: memo ?? e.memo,
            countPresent: countPresent ?? e.countPresent,
            countAbsent: countAbsent ?? e.countAbsent,
            countLate: countLate ?? e.countLate,
            createdAt: e.createdAt
        )
    }
}

private struct CreateTimetableResponse: Decodable { let id: String }
