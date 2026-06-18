import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func performLogin() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let response: AuthResponse = try await APIClient.shared.request(
                    APIEndpoint.url("/auth/login"),
                    method: "POST",
                    body: LoginRequest(email: email, password: password),
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

    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
}
