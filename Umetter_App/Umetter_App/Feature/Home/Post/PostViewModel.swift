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
        return hasRealContent(content)
    }

    private func hasRealContent(_ text: String) -> Bool {
        let normalized = text
            .replacingOccurrences(of: "　", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // #給食 や #休講情報 みたいなハッシュタグ部分を消す
        let textWithoutTags = normalized
            .replacingOccurrences(of: "#\\S+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ハッシュタグを消した後に文字が残っていれば投稿OK
        return !textWithoutTags.isEmpty
    }
    
    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 先頭の # を全部取り除く
        let tagBody = trimmed
            .replacingOccurrences(of: "^#+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // # だけ、空白だけなら追加しない
        guard !tagBody.isEmpty else {
            newTagText = ""
            return
        }
        
        let formattedTag = "#\(tagBody)"
        
        guard !addedTags.contains(formattedTag) else {
            newTagText = ""
            return
        }
        
        addedTags.append(formattedTag)
        newTagText = ""
    }
    
    func removeTag(_ tag: String) {
        addedTags.removeAll { $0 == tag }
    }
    
    func submitPost() -> PostModel? {
        guard canSubmit else {
            return nil
        }
        
        repository.saveTags(addedTags)
        loadSuggestedTags()
        
        let newPost = PostModel(
            id: UUID(),
            userName: "名無しさん",
            createdAt: Date(),
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
