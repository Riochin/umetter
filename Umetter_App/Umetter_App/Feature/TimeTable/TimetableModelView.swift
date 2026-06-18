import SwiftUI
import Combine

class TimetableModelView: ObservableObject {
    @Published var showWeekend = false
    @Published var showPeriod6 = false

    @Published var showingSettings = false
    @Published var showingPicker = false
    @Published var showingEditSheet = false
    @Published var showingClassSearch = false

    @Published var editKey = ""
    @Published var editSubject = ""
    @Published var editRoom = ""
    @Published var editColor: SlotColor = .blue
    @Published var isOndemandEdit = false

    @Published var selectedYear = "2026年"
    @Published var selectedTerm = "1ターム"

    let allDays = ["月", "火", "水", "木", "金", "土", "日"]
    let allPeriods = [
        (1, "08:50\n|\n10:20"), (2, "10:30\n|\n12:00"),
        (3, "13:00\n|\n14:30"), (4, "14:40\n|\n16:10"),
        (5, "16:20\n|\n17:50"), (6, "18:00\n|\n19:30")
    ]
    let years  = ["2024年", "2025年", "2026年", "2027年", "2028年", "2029年", "2030年"]
    let terms  = ["1ターム", "2ターム", "3ターム", "4ターム"]

    @Published var allOndemandData: [String: [String: TimetableSlot]] = [:]

    private var cancellables = Set<AnyCancellable>()

    init() {
        TimetableStore.shared.$entries
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var currentTermKey: String { "\(selectedYear)_\(selectedTerm)" }

    // MARK: - API-backed timetable

    var allTimetableData: [String: [String: TimetableSlot]] {
        var result: [String: [String: TimetableSlot]] = [:]
        for entry in TimetableStore.shared.entries {
            let tk  = TimetableStore.termKey(term: entry.term, year: selectedYear)
            let day = TimetableStore.dayString(from: entry.dayOfWeek)
            let sk  = "\(day)-\(entry.period)"
            result[tk, default: [:]][sk] = TimetableSlot(
                subject: entry.name,
                room: entry.room,
                themeColor: .blue
            )
        }
        return result
    }

    func getTimetableSlot(key: String) -> TimetableSlot? {
        allTimetableData[currentTermKey]?[key]
    }

    func getOndemandSlot(key: String) -> TimetableSlot? {
        allOndemandData[currentTermKey]?[key]
    }

    // MARK: - Actions

    func openEditSheet(key: String, isOndemand: Bool, slot: TimetableSlot?) {
        editKey = key
        isOndemandEdit = isOndemand
        if let existing = slot {
            editSubject = existing.subject
            editRoom = existing.room
            editColor = existing.themeColor
        } else {
            editSubject = ""
            editRoom = ""
            editColor = .blue
        }
        showingEditSheet = true
    }

    func saveSlot() {
        if editSubject.isEmpty { deleteSlot(); return }

        if isOndemandEdit {
            let newSlot = TimetableSlot(subject: editSubject, room: editRoom, themeColor: editColor)
            if allOndemandData[currentTermKey] == nil { allOndemandData[currentTermKey] = [:] }
            allOndemandData[currentTermKey]?[editKey] = newSlot
            showingEditSheet = false
            return
        }

        // 既存 entry のメモ更新（day-period キーから逆引き）
        let parts = editKey.split(separator: "-")
        if parts.count == 2, let period = Int(parts[1]) {
            let dayStr = String(parts[0])
            let termStr = apiTerm(from: selectedTerm)
            let dayNum = dayOfWeekInt(from: dayStr)
            if let entry = TimetableStore.shared.entries.first(where: {
                $0.dayOfWeek == dayNum && $0.period == period && $0.term == termStr
            }) {
                Task { try? await TimetableStore.shared.updateEntry(id: entry.id, memo: editSubject) }
            }
        }
        showingEditSheet = false
    }

    func deleteSlot() {
        if isOndemandEdit {
            allOndemandData[currentTermKey]?.removeValue(forKey: editKey)
        }
        showingEditSheet = false
    }

    func loadTimetable() async {
        await TimetableStore.shared.loadFromAPI()
    }

    // MARK: - Private helpers

    private func apiTerm(from term: String) -> String {
        switch term {
        case "1ターム": return "T1"
        case "2ターム": return "T2"
        case "3ターム": return "T3"
        case "4ターム": return "T4"
        default:        return term
        }
    }

    private func dayOfWeekInt(from day: String) -> Int {
        switch day {
        case "日": return 0
        case "月": return 1
        case "火": return 2
        case "水": return 3
        case "木": return 4
        case "金": return 5
        case "土": return 6
        default:   return 1
        }
    }

    // MARK: - Notifications (仮)

    @Published var activeAlert: String? = nil
    func fetchActiveAlert() {
        let pinned = PostStore.shared.posts.filter { $0.isPinned }.first
        if let p = pinned {
            activeAlert = p.body
        }
    }
}
