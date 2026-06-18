import SwiftUI

struct ClassSearchView: View {
    let termKey: String
    @Environment(\.dismiss) private var dismiss

    @State private var keyword = ""
    @State private var results: [ClassResponse] = []
    @State private var isSearching = false
    @State private var errorMessage: String? = nil
    @State private var addingId: String? = nil
    @State private var successIds: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("科目名・教員名で検索", text: $keyword)
                        .submitLabel(.search)
                        .onSubmit { Task { await search() } }
                    if !keyword.isEmpty {
                        Button(action: { keyword = ""; results = [] }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()

                if let msg = errorMessage {
                    Text(msg).foregroundColor(.red).font(.caption).padding(.horizontal)
                }

                if isSearching {
                    ProgressView().padding()
                } else if results.isEmpty && !keyword.isEmpty {
                    Text("該当する科目が見つかりませんでした")
                        .font(.footnote).foregroundColor(.gray).padding()
                } else {
                    List(results, id: \.id) { cls in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cls.name)
                                    .font(.subheadline).fontWeight(.semibold)
                                Text("\(cls.teacherName)  \(termLabel(cls.term)) \(dayLabel(cls.dayOfWeek))\(cls.period)限  \(cls.room)")
                                    .font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            if successIds.contains(cls.id) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            } else {
                                Button(action: { Task { await addToTimetable(cls) } }) {
                                    if addingId == cls.id {
                                        ProgressView().frame(width: 28, height: 28)
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2).foregroundColor(.umeRed)
                                    }
                                }
                                .disabled(addingId != nil)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("科目を検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }.foregroundColor(.umeRed)
                }
            }
        }
    }

    private func search() async {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }
        do {
            let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
            let response: ClassListResponse = try await APIClient.shared.request(
                APIEndpoint.url("/classes?keyword=\(encoded)")
            )
            results = response.classes
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "検索に失敗しました"
        }
    }

    private func addToTimetable(_ cls: ClassResponse) async {
        addingId = cls.id
        defer { addingId = nil }
        do {
            try await TimetableStore.shared.addEntry(classId: cls.id)
            successIds.insert(cls.id)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "追加に失敗しました"
        }
    }

    private func termLabel(_ term: String) -> String {
        switch term {
        case "T1": return "T1"
        case "T2": return "T2"
        case "T3": return "T3"
        case "T4": return "T4"
        default:   return term
        }
    }

    private func dayLabel(_ dayOfWeek: Int) -> String {
        TimetableStore.dayString(from: dayOfWeek)
    }
}
