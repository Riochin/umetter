import Foundation

enum APIEndpoint {
    static var baseURL = "http://localhost:8080/api/v1"

    static func url(_ path: String) -> URL {
        URL(string: baseURL + path)!
    }
}
