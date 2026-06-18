import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let displayName: String
}

struct VerifyEmailRequest: Encodable {
    let email: String
    let code: String
}

struct AuthResponse: Decodable {
    let token: String
    let user: UserResponse
}

struct RegisterResponse: Decodable {
    let message: String
    let email: String
    let debugCode: String?
}
