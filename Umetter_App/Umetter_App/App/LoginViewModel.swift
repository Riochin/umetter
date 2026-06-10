//
//  LoginViewModel.swift
//  Umetter_App
//
//  Created by 悠 on 2026/06/05.
//
import SwiftUI
import Combine

/// ViewとModelの橋渡しを行い、状態管理とビジネスロジックを担当します。
@MainActor
class LoginViewModel: ObservableObject {
    // ユーザー入力
    @Published var username = ""
    @Published var password = ""
    
    // UIの状態
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var isLoggedIn = false
    
    /// ログイン処理を実行します
    func performLogin() {
        isLoading = true
        
        // API通信などの重い処理をシミュレート
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoading = false
            self.isLoggedIn = true
            print("ログイン成功: \(self.username)")
            
            // 成功した場合はここでModelを生成したり、画面遷移を指示したりします
            // let user = User(username: self.username)
        }
    }
    
    /// パスワードの表示/非表示を切り替えます
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
}
