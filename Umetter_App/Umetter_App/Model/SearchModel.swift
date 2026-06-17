import Foundation

// 検索結果の投稿データ
struct Post: Identifiable {
    let id: Int
    let userName: String
    let timeAgo: String
    let content: String
    let tags: [String]
    let likes: Int
}

// 検索タブの種類
enum SearchTab {
    case top
    case latest
}

// 画面の表示状態
enum ViewState {
    case history
    case suggesting
    case results
}
