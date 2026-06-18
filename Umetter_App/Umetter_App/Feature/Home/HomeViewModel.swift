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

    func loadPosts() async {
        await PostStore.shared.loadFromAPI()
    }

    func addSearchHistory(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let tag = trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
        tagHistory.removeAll { $0 == tag }
        tagHistory.insert(tag, at: 0)
    }

    func toggleLike(for post: PostModel) {
        PostStore.shared.toggleLike(for: post.id)
    }

    func toggleSave(for post: PostModel) {
        PostStore.shared.toggleSave(for: post.id)
    }
}
