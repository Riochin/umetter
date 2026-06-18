//
//  SearchViewModel.swift
//  Umetter_App
//
//  Created by 小宮あかり on 2026/06/17.
//

import Foundation
import Combine

// MARK: - ViewModel
class SearchViewModel: ObservableObject {
    // Viewにバインディングする状態（State）
    @Published var searchText: String = "" {
        didSet { textDidChange() }
    }
    @Published var searchHistory: [String] = ["#サークル勧誘", "#休講情報", "お昼ご飯"]
    @Published var currentViewState: ViewState = .history
    @Published var currentTab: SearchTab = .top {
        didSet { sortResults() }
    }
    
    @Published var suggestedTags: [String] = []
    @Published var searchResults: [PostModel] = []
    
    // バックエンド/DBの代わりとなるモックデータ
        // チームのPostModelに合わせて、UUID()や現在時刻からの引き算(Date().addingTimeInterval)を使っています
        private let allPosts: [PostModel] = [
            PostModel(id: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-600), content: "今日の2限の〇〇先生の授業、休講になったらしい！", tags: ["#休講情報", "#学芸学部"], imageUrl: nil, likesCount: 5, isLiked: false, isSaved: false),
            
            PostModel(id: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-3600), content: "🌸テニスサークル 新歓のお知らせ🌸\n今週金曜日の放課後、テニスコートで体験会をやります！初心者も経験者も大歓迎です✨", tags: ["#サークル勧誘", "#春から津田塾"], imageUrl: nil, likesCount: 32, isLiked: false, isSaved: true),
            
            PostModel(id: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-7200), content: "お昼ご飯、誰か一緒に食べませんか？今ルネにいます！", tags: ["お昼ご飯"], imageUrl: nil, likesCount: 12, isLiked: false, isSaved: false),
            
            PostModel(id: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-86400), content: "財布を落としました。見つけた方いらっしゃいませんか？", tags: ["#落とし物"], imageUrl: nil, likesCount: 2, isLiked: false, isSaved: false)
        ]
    
    private let allTags = ["#休講情報", "#学芸学部", "#サークル勧誘", "#春から津田塾", "#落とし物", "#質問", "#雑談"]
    
    // MARK: - Inputs (Viewからのアクション)
    
    private func textDidChange() {
        if searchText.isEmpty {
            currentViewState = .history
        } else if currentViewState != .results {
            currentViewState = .suggesting
            updateSuggestions()
        }
    }
    
    private func updateSuggestions() {
        let query = searchText.lowercased()
        suggestedTags = allTags.filter { $0.lowercased().contains(query) }
    }
    
    func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }
        
        //追加したよ　全角入力しかできなくて、検索履歴の#は半角だったため
        let fixedQuery = trimmedQuery.replacingOccurrences(of: "＃", with: "#")
        
        searchText = fixedQuery
        currentViewState = .results
        addToHistory(query: fixedQuery)
        
        // 検索実行（本文またはタグに一致）
        let lowerQuery = fixedQuery.lowercased()
        searchResults = allPosts.filter { post in
            post.content.lowercased().contains(lowerQuery) ||
            post.tags.contains { $0.lowercased().contains(lowerQuery) }
        }
        
        sortResults()
    }
    
    func switchTab(to tab: SearchTab) {
        currentTab = tab
    }
    
    private func sortResults() {
        if currentTab == .top {
            searchResults.sort { $0.likesCount > $1.likesCount } // いいね順
        } else {
            searchResults.sort { $0.createdAt > $1.createdAt } // 最新順（ID降順）
        }
    }
    
    // MARK: - History Management
    
    private func addToHistory(query: String) {
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        if searchHistory.count > 10 {
            searchHistory.removeLast()
        }
    }
    
    func removeHistoryItem(_ item: String) {
        searchHistory.removeAll { $0 == item }
    }
    
    func clearAllHistory() {
        searchHistory.removeAll()
    }
}
