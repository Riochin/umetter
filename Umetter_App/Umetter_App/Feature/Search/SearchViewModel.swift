import SwiftUI
import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var currentViewState: SearchViewState = .empty
    @Published var searchResults: [PostModel] = []
    
    // 最近の検索履歴の初期データ
    @Published var searchHistory: [String] = ["#サークル勧誘", "お昼ご飯", "落とし物", "休講"]
    
    @Published var currentTab: SearchTab = .top {
        didSet {
            sortResults()
        }
    }

    // ※モックデータ（allPosts）は削除し、チームの PostStore を使います！

    func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        // 全角の「＃」を半角の「#」に自動置換する
        let fixedQuery = trimmedQuery.replacingOccurrences(of: "＃", with: "#")

        searchText = fixedQuery
        currentViewState = .results
        addToHistory(query: fixedQuery)

        let lowerQuery = fixedQuery.lowercased()
        
        // 👇 【ここがポイント！】チーム共通の PostStore から最新データを引っ張ってきて検索する
        searchResults = PostStore.shared.posts.filter { post in
            post.content.lowercased().contains(lowerQuery) ||
            post.tags.contains { $0.lowercased().contains(lowerQuery) }
        }

        sortResults()
    }

    private func sortResults() {
        if currentTab == .top {
            searchResults.sort { $0.likesCount > $1.likesCount } // いいね順
        } else {
            searchResults.sort { $0.createdAt > $1.createdAt } // 最新順
        }
    }

    private func addToHistory(query: String) {
        if let index = searchHistory.firstIndex(of: query) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(query, at: 0)
        // 履歴は最大10件まで保持
        if searchHistory.count > 10 {
            searchHistory.removeLast()
        }
    }

    func clearHistory() {
        searchHistory.removeAll()
    }

    func removeHistoryItem(at index: Int) {
        searchHistory.remove(at: index)
    }
}
