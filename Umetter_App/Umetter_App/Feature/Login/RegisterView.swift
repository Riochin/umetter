import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.umeBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(12)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                Spacer()

                VStack(spacing: 8) {
                    UmeFlowerView(size: 72)
                    Text(viewModel.step == 1 ? "アカウント作成" : "メール認証")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.umeRed)
                        .kerning(1.5)
                }
                .padding(.bottom, 40)

                if viewModel.step == 1 {
                    step1Form
                } else {
                    step2Form
                }

                Spacer()

                Text("© Tsuda University & Umetter Project 2026")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.bottom, 24)
            }
        }
    }

    private var step1Form: some View {
        VStack(spacing: 16) {
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            fieldRow(icon: "person.fill", placeholder: "表示名（任意）", text: $viewModel.displayName)
            fieldRow(icon: "envelope.fill", placeholder: "大学メールアドレス", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            fieldRow(icon: "lock.fill", placeholder: "パスワード（8文字以上）", text: $viewModel.password, secure: true)

            Button(action: viewModel.register) {
                actionLabel("登録メールを送信", isLoading: viewModel.isLoading)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 24)
    }

    private var step2Form: some View {
        VStack(spacing: 16) {
            Text("メールに届いた6桁の認証コードを入力してください。")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            fieldRow(icon: "key.fill", placeholder: "認証コード（6桁）", text: $viewModel.verifyCode)
                .keyboardType(.numberPad)

            Button(action: viewModel.verifyEmail) {
                actionLabel("認証して始める", isLoading: viewModel.isLoading)
            }
            .disabled(viewModel.isLoading)

            Button(action: { viewModel.step = 1 }) {
                Text("メールアドレスを変更する")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .underline()
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func fieldRow(icon: String, placeholder: String, text: Binding<String>, secure: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray.opacity(0.5))
                .frame(width: 24)
            if secure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 14, weight: .medium))
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderColor, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
    }

    private func actionLabel(_ title: String, isLoading: Bool) -> some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            Text(isLoading ? "送信中..." : title)
                .font(.system(size: 16, weight: .bold))
                .kerning(1.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.umeRed)
        .foregroundColor(.white)
        .cornerRadius(16)
        .shadow(color: Color.umeRed.opacity(0.1), radius: 5, y: 3)
    }
}
