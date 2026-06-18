import SwiftUI
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var verifyCode = ""

    @Published var step = 1
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var registeredEmail = ""

    func register() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let _: RegisterResponse = try await APIClient.shared.request(
                    APIEndpoint.url("/auth/register"),
                    method: "POST",
                    body: RegisterRequest(email: email, password: password, displayName: displayName),
                    requiresAuth: false
                )
                registeredEmail = email
                step = 2
            } catch let error as APIError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "予期しないエラーが発生しました"
            }
        }
    }

    func verifyEmail() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let response: AuthResponse = try await APIClient.shared.request(
                    APIEndpoint.url("/auth/verify-email"),
                    method: "POST",
                    body: VerifyEmailRequest(email: registeredEmail, code: verifyCode),
                    requiresAuth: false
                )
                UserStore.shared.login(user: response.user, token: response.token)
            } catch let error as APIError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "予期しないエラーが発生しました"
            }
        }
    }
}
