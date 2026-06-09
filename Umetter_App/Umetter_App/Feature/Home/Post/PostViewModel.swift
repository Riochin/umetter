import Foundation
import Combine

class PostViewModel: ObservableObject {
    
    @Published var content: String = ""
    @Published var addedTags: [String] = []
    @Published var newTagText: String = ""
    @Published var suggestedTags: [String] = []
    
    private let repository = HashtagRepository()
    
    init() {
        loadSuggestedTags()
    }
    
    var canSubmit: Bool {
        return !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !addedTags.isEmpty
    }
    
    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let formattedTag = trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
        
        if !addedTags.contains(formattedTag) {
            addedTags.append(formattedTag)
        }
        
        newTagText = ""
    }
    
    func removeTag(_ tag: String) {
        addedTags.removeAll { $0 == tag }
    }
    
    func submitPost() -> PostModel? {
        repository.saveTags(addedTags)
        loadSuggestedTags()
        
        let newPost = PostModel(
            id: UUID(),
            userName: "名無しさん",
            createdAt:Date(),
            content: content,
            tags: addedTags,
            imageUrl: nil,
            likesCount: 0,
            isLiked: false,
            isSaved: false
        )
        
        return newPost
    }
    
    private func loadSuggestedTags() {
        suggestedTags = repository.fetchSuggestedTags()
    }
}
