import SwiftUI

struct MainTabView: View {
    // ユーザー情報などが必要な場合はここで保持します
    // private let profile: UserProfile
    
    // 各タブで使うViewModelを定義
    @State private var homeViewModel: HomeViewModel
    // 今後、時間割や通知の機能を作る際に以下のように追加していきます
    // @State private var calendarViewModel: CalendarViewModel
    // @State private var notificationViewModel: NotificationViewModel

    init() {
        // ViewModelの初期化
        _homeViewModel = State(initialValue: HomeViewModel())
    }

    var body: some View {
        TabView {
            // 1. ホーム画面（タイムラインと右上の検索）
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: "house.fill")
            }

            // 2. カレンダー画面（時間割とオンデマンド）
            NavigationStack {
                // TODO: CalendarView() に置き換える
                Text("時間割・カレンダー画面をここに作ります")
                    .navigationTitle("時間割")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("カレンダー", systemImage: "calendar")
            }

            // 3. 通知画面（アラーム機能や通知一覧）
            NavigationStack {
                            // TODO: SearchView() に置き換える
                            Text("検索画面をここに作ります")
                                .navigationTitle("検索")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .tabItem {
                            Label("検索", systemImage: "magnifyingglass")
                        }

            // 4. マイページ画面（プロフィール設定やブックマーク確認）
            NavigationStack {
                // TODO: AccountView() に置き換える
                AccountView()
            }
            .tabItem {
                Label("アカウント", systemImage: "person.fill")
            }
        }
        // 選択されたタブのアイコン色を「うめったー」のメインカラー（えんじ色）に設定
        .tint(Color.umeRed)
    }
}

#Preview {
    MainTabView()
}
