import Foundation

@MainActor
final class APIClient {
    static let shared = APIClient()

    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    private let encoder = JSONEncoder()

    private init() {}

    func request<T: Decodable>(
        _ url: URL,
        method: String = "GET",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = KeychainHelper.load() else {
                await UserStore.shared.logout()
                throw APIError.unauthorized
            }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw APIError.networkUnavailable
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError
        }

        switch http.statusCode {
        case 200, 201, 202:
            break
        case 401:
            await UserStore.shared.logout()
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 409:
            let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "すでに存在します"
            throw APIError.conflict(msg)
        case 500...:
            throw APIError.serverError
        default:
            let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "エラーが発生しました"
            throw APIError.custom(msg)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

private struct ErrorResponse: Decodable {
    let error: String
}
