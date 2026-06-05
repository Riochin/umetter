import Foundation
import Combine

// ホーム画面のデータと処理を管理するViewModel
final class HomeViewModel: ObservableObject {

    // タイムラインに表示する投稿一覧
    @Published var posts: [PostModel] = []

    // 検索したタグの履歴
    @Published var tagHistory: [String] = []

    init() {
        loadMockData()
    }

    // 最初から表示するサンプル投稿
    private func loadMockData() {
        posts = [
            PostModel(
                id: UUID(),
                userName: "名無しさん",
                timeAgo: "10分前",
                content: "今日の2限の〇〇先生の授業、休講になったらしい！サイトにも出てる。",
                tags: ["#休講情報", "#学芸学部"],
                imageUrl: nil,
                likesCount: 12,
                isLiked: false,
                isSaved: false
            )
        ]
    }

    // 検索したタグを履歴に追加する処理
    func addSearchHistory(_ text: String) {
        // 空白や改行を消す
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 空なら追加しない
        guard !trimmed.isEmpty else {
            return
        }

        // # がなければ付ける
        let tag = trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"

        // 同じタグがすでにあれば一度消す
        tagHistory.removeAll { $0 == tag }

        // 最新の履歴を一番前に追加する
        tagHistory.insert(tag, at: 0)
    }

    // 新しい投稿を追加する処理
    func addPost(content: String, tags: [String]) {
        // 空白や改行だけの投稿を防ぐ
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)

        // 本文が空なら投稿しない
        guard !text.isEmpty else {
            return
        }

        // 新しい投稿データを作る
        let newPost = PostModel(
            id: UUID(),
            userName: "名無しさん",
            timeAgo: "今",
            content: text,
            tags: tags,
            imageUrl: nil,
            likesCount: 0,
            isLiked: false,
            isSaved: false
        )

        // ホーム画面の一番上に投稿を追加する
        posts.insert(newPost, at: 0)
    }

    // いいねを切り替える処理
    func toggleLike(for post: PostModel) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            return
        }

        posts[index].isLiked.toggle()

        if posts[index].isLiked {
            posts[index].likesCount += 1
        } else {
            posts[index].likesCount -= 1
        }
    }

    // 保存を切り替える処理
    func toggleSave(for post: PostModel) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            return
        }

        posts[index].isSaved.toggle()
    }
}
