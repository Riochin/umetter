
import Foundation

struct HashtagRepository {
    // 過去の配列データとぶつからないように保存キーを新しいものに変更
    private let historyCountsKey = "HashtagHistoryCounts"
    private let defaultTags = ["#休講情報", "#サークル勧誘", "#落とし物", "#質問", "#雑談"]
    
    /// おすすめタグのリストを取得する (使用回数が多い順)
    func fetchSuggestedTags() -> [String] {
        // UserDefaults から 辞書 [タグ名: 使用回数] を取得（なければ空の辞書）
        let historyCounts = UserDefaults.standard.dictionary(forKey: historyCountsKey) as? [String: Int] ?? [:]
        
        // 【重要】回数が多い順 ＋ 回数が同じなら名前順でソート（毎回順番が変わるのを防ぐ）
        let sortedHistory = historyCounts.sorted {
            if $0.value != $1.value {
                return $0.value > $1.value // 回数が多い順
            } else {
                return $0.key < $1.key     // 回数が同じならアルファベット/五十音順
            }
        }.map { $0.key }
        
        var combinedTags = sortedHistory
        
        // 履歴にないデフォルトタグを後ろにくっつける
        for tag in defaultTags {
            if !combinedTags.contains(tag) {
                combinedTags.append(tag)
            }
        }
        
        // 最大10個まで返す
        return Array(combinedTags.prefix(10))
    }
    
    /// 使ったタグを履歴に保存する (使用回数をカウントアップ)
    func saveTags(_ tags: [String]) {
        guard !tags.isEmpty else { return }
        
        // 現在のカウント辞書を取得
        var historyCounts = UserDefaults.standard.dictionary(forKey: historyCountsKey) as? [String: Int] ?? [:]
        
        // 使われたタグのカウントを 1 増やす
        for tag in tags {
            historyCounts[tag, default: 0] += 1
        }
        
        // 更新した辞書を UserDefaults に保存
        UserDefaults.standard.set(historyCounts, forKey: historyCountsKey)
    }
}
