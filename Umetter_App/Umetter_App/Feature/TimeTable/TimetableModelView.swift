import SwiftUI
import Combine

class TimetableModelView: ObservableObject {
    @Published var showWeekend = false
    @Published var showPeriod6 = false

    
    @Published var showingSettings = false
    @Published var showingPicker = false
    @Published var showingEditSheet = false
    
    @Published var editKey = ""
    @Published var editSubject = ""
    @Published var editRoom = ""
    @Published var editColor: SlotColor = .blue
    @Published var isOndemandEdit = false
    
    // 選択中の年とターム
    @Published var selectedYear = "2026年"
    @Published var selectedTerm = "1ターム"
    
    let allDays = ["月", "火", "水", "木", "金", "土", "日"]
    let allPeriods = [
        (1, "08:50\n|\n10:20"), (2, "10:30\n|\n12:00"),
        (3, "13:00\n|\n14:30"), (4, "14:40\n|\n16:10"),
        (5, "16:20\n|\n17:50"), (6, "18:00\n|\n19:30")
    ]
    
    let years = ["2024年", "2025年", "2026年", "2027年","2028年","2029年","2030年"]
    let terms = ["1ターム", "2ターム", "3ターム", "4ターム"]
    
    // 👇 変更点：すべての学期のデータを保持する2階層の辞書に変更
    // Key: "2026年_1学期" -> Value: ["月-1": TimetableSlot]
    @Published var allTimetableData: [String: [String: TimetableSlot]] = [
        "2026年_1ターム": [
            "月-1": TimetableSlot(subject: "社会学概論", room: "1203", themeColor: .blue),
            "月-2": TimetableSlot(subject: "コンパイラ構成", room: "端末室", themeColor: .pink),
            "火-1": TimetableSlot(subject: "マーケティング論", room: "6101", themeColor: .orange),
            "木-2": TimetableSlot(subject: "地球の科学", room: "1102", themeColor: .blue),
            "木-3": TimetableSlot(subject: "英語リスニング", room: "オンライン", themeColor: .green),
            "金-4": TimetableSlot(subject: "心理学", room: "6B13", themeColor: .purple)
        ]
    ]
    
    @Published var allOndemandData: [String: [String: TimetableSlot]] = [
        "2026年_1ターム": [
            "水": TimetableSlot(subject: "情報倫理", room: "", themeColor: .blue)
        ]
    ]
    
    // 👇 追加：現在の「年_ターム」のキーを作成する計算プロパティ
    var currentTermKey: String {
        return "\(selectedYear)_\(selectedTerm)"
    }
    
    // 👇 追加：現在の学期の特定のコマを取得する関数
    func getTimetableSlot(key: String) -> TimetableSlot? {
        return allTimetableData[currentTermKey]?[key]
    }
    
    func getOndemandSlot(key: String) -> TimetableSlot? {
        return allOndemandData[currentTermKey]?[key]
    }
    
    // MARK: - アクションロジック
    
    func openEditSheet(key: String, isOndemand: Bool, slot: TimetableSlot?) {
        self.editKey = key
        self.isOndemandEdit = isOndemand
        
        if let existing = slot {
            self.editSubject = existing.subject
            self.editRoom = existing.room
            self.editColor = existing.themeColor
        } else {
            self.editSubject = ""
            self.editRoom = ""
            self.editColor = .blue
        }
        self.showingEditSheet = true
    }
    
    func saveSlot() {
        if editSubject.isEmpty {
            deleteSlot()
            return
        }
        
        let newSlot = TimetableSlot(subject: editSubject, room: editRoom, themeColor: editColor)
        
        if isOndemandEdit {
            // その学期の箱がまだ無ければ作る
            if allOndemandData[currentTermKey] == nil { allOndemandData[currentTermKey] = [:] }
            allOndemandData[currentTermKey]?[editKey] = newSlot
        } else {
            if allTimetableData[currentTermKey] == nil { allTimetableData[currentTermKey] = [:] }
            allTimetableData[currentTermKey]?[editKey] = newSlot
        }
        showingEditSheet = false
    }
    
    func deleteSlot() {
        if isOndemandEdit {
            allOndemandData[currentTermKey]?.removeValue(forKey: editKey)
        } else {
            allTimetableData[currentTermKey]?.removeValue(forKey: editKey)
        }
        showingEditSheet = false
    }
    
    // 通知取得（仮）
    @Published var activeAlert: String? = nil
    func fetchActiveAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activeAlert = "【重要】休講情報: 12/24(金) の英語リスニングは休講です"
        }
    }
}
