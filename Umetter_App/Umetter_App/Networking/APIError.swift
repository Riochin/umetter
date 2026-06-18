import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case conflict(String)
    case serverError
    case decodingFailed
    case networkUnavailable
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:        return "ログインが必要です"
        case .forbidden:           return "アクセス権限がありません"
        case .notFound:            return "見つかりませんでした"
        case .conflict(let msg):   return msg
        case .serverError:         return "サーバーエラーが発生しました"
        case .decodingFailed:      return "データの読み込みに失敗しました"
        case .networkUnavailable:  return "ネットワークに接続できません"
        case .custom(let msg):     return msg
        }
    }
}
