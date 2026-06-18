import SwiftUI

@main
struct Umetter_AppApp: App {
    @StateObject private var userStore = UserStore.shared

    var body: some Scene {
        WindowGroup {
            if userStore.currentUser != nil {
                MainTabView(initialTab: 1)
            } else {
                LoginView()
                    .task {
                        guard KeychainHelper.load() != nil else { return }
                        try? await UserStore.shared.refreshMe()
                    }
            }
        }
    }
}
