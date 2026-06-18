import Foundation
import Combine

@MainActor
class PostViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var addedTags: [String] = []
    @Published var newTagText: String = ""
    @Published var suggestedTags: [String] = []
    @Published var isSubmitting = false
    @Published var errorMessage: String? = nil

    private let repository = HashtagRepository()

    init() {
        loadSuggestedTags()
    }

    var canSubmit: Bool { hasRealContent(content) && !isSubmitting }

    private func hasRealContent(_ text: String) -> Bool {
        let normalized = text
            .replacingOccurrences(of: "　", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let textWithoutTags = normalized
            .replacingOccurrences(of: "#\\S+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return !textWithoutTags.isEmpty
    }

    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        let tagBody = trimmed
            .replacingOccurrences(of: "^#+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tagBody.isEmpty else { newTagText = ""; return }
        let formatted = "#\(tagBody)"
        guard !addedTags.contains(formatted) else { newTagText = ""; return }
        addedTags.append(formatted)
        newTagText = ""
    }

    func removeTag(_ tag: String) {
        addedTags.removeAll { $0 == tag }
    }

    func submitPost() async throws {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let category = addedTags.first?
            .replacingOccurrences(of: "^#+", with: "", options: .regularExpression) ?? "all"

        repository.saveTags(addedTags)
        loadSuggestedTags()

        try await PostStore.shared.createPost(body: content, category: category)
    }

    private func loadSuggestedTags() {
        suggestedTags = repository.fetchSuggestedTags()
    }
}
