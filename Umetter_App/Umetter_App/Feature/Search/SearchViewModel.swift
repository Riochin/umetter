//
//  SearchViewModel.swift
//  Umetter_App
//
//  Created by 小宮あかり on 2026/06/19.
//
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

    // バックエンド/DBの代わりとなるモックデータ（チームのPostModelに準拠）
    // 👇 userId: "user1" などを追加しました！
    // バックエンド/DBの代わりとなるモックデータ（チームのPostModelに準拠）
        private let allPosts: [PostModel] = [
            PostModel(id: UUID(), userId: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-600), content: "今日の2限の〇〇先生の授業、休講になったらしい！", tags: ["#休講", "#学芸学部"], imageUrl: nil, likesCount: 5, isLiked: false, isSaved: false),
            
            PostModel(id: UUID(), userId: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-3600), content: "🌸テニスサークル 新歓のお知らせ🌸\n今週金曜日の放課後、テニスコートで体験会をやります！初心者も経験者も大歓迎です✨", tags: ["#サークル勧誘", "#春から津田塾"], imageUrl: nil, likesCount: 32, isLiked: false, isSaved: true),
            
            PostModel(id: UUID(), userId: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-7200), content: "お昼ご飯、誰か一緒に食べませんか？今ルネにいます！", tags: ["お昼ご飯"], imageUrl: nil, likesCount: 12, isLiked: false, isSaved: false),
            
            PostModel(id: UUID(), userId: UUID(), userName: "名無しさん", createdAt: Date().addingTimeInterval(-86400), content: "財布を落としました。見つけた方いらっしゃいませんか？", tags: ["落とし物"], imageUrl: nil, likesCount: 2, isLiked: false, isSaved: false)
        ]

    func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        // 全角の「＃」を半角の「#」に自動置換する
        let fixedQuery = trimmedQuery.replacingOccurrences(of: "＃", with: "#")

        searchText = fixedQuery
        currentViewState = .results
        addToHistory(query: fixedQuery)

        let lowerQuery = fixedQuery.lowercased()
        searchResults = allPosts.filter { post in
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
