import SwiftUI

/// メインログインビュー
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    // View固有のアニメーション状態
    @State private var isBouncing = false
    
    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                MainTabView(initialTab: 1)
            } else {
                ZStack {
                    Color.umeBackground.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // メインロゴ・ヘッダー
                        VStack(spacing: 16) {
                            UmeFlowerView(size: 112)
                                .shadow(color: Color.umeRed.opacity(0.15), radius: 10, x: 0, y: 10)
                                .offset(y: isBouncing ? -15 : 0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isBouncing)
                                .onAppear { isBouncing = true }
                            
                            VStack(spacing: 4) {
                                Text("うめったー")
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(.umeRed)
                                    .kerning(2.0)
                                Text("津田塾大学 ポータルログイン")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.umeRed.opacity(0.9))
                                    .kerning(1.0)
                            }
                            
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.umeRed.opacity(0.3))
                                .frame(width: 64, height: 2)
                        }
                        .padding(.bottom, 48)
                        
                        // フォーム
                        VStack(spacing: 16) {
                            Text("ユーザ名とパスワードを入力してください。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray.opacity(0.9))
                            
                            // ユーザー名
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(width: 24)
                                TextField("ユーザー名", text: $viewModel.username)
                                    .font(.system(size: 14, weight: .medium))
                                    .autocapitalization(.none)
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderColor, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
                            
                            // パスワード
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(width: 24)
                                
                                if viewModel.isPasswordVisible {
                                    TextField("パスワード", text: $viewModel.password)
                                        .font(.system(size: 14, weight: .medium))
                                } else {
                                    SecureField("パスワード", text: $viewModel.password)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                
                                Button(action: viewModel.togglePasswordVisibility) {
                                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderColor, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
                            
                            // ログインボタン
                            Button(action: viewModel.performLogin) {
                                HStack(spacing: 8) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("ログイン中...")
                                            .font(.system(size: 16, weight: .bold))
                                    } else {
                                        Text("ログイン")
                                            .font(.system(size: 16, weight: .bold))
                                            .kerning(2.0)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.umeRed)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.umeRed.opacity(0.1), radius: 5, y: 3)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        // フッター
                        VStack(spacing: 8) {
                            Button(action: {}) {
                                Text("パスワードを忘れた場合")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .underline()
                            }
                            Text("© Tsuda University & Umetter Project 2026")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

// プレビュー用
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
