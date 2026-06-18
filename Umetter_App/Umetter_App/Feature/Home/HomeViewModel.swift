import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    @Published var tagHistory: [String] = []
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        PostStore.shared.$posts
            .assign(to: &$posts)
    }
    
    // 検索したタグを履歴に追加する処理
    func addSearchHistory(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let tag = trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
        tagHistory.removeAll { $0 == tag }
        tagHistory.insert(tag, at: 0)
    }

    // 新しい投稿を追加する処理
    func addPost(_ newPost: PostModel) {
        PostStore.shared.addPost(newPost)
    }

    // いいねを切り替える処理
    func toggleLike(for post: PostModel) {
        PostStore.shared.toggleLike(for: post.id)
    }

    // 保存を切り替える処理
    func toggleSave(for post: PostModel) {
        PostStore.shared.toggleSave(for: post.id)
    }
}
