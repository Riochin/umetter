import SwiftUI

struct MainTabView: View {
    // ユーザー情報などが必要な場合はここで保持します
    // private let profile: UserProfile
    
    // 現在選択されているタブ
    @State private var selectedTab: Int
    
    // 各タブで使うViewModelを定義
    @State private var homeViewModel: HomeViewModel
    // 今後、時間割や通知の機能を作る際に以下のように追加していきます
    // @State private var calendarViewModel: CalendarViewModel
    // @State private var notificationViewModel: NotificationViewModel

    init(initialTab: Int = 1) {
        // ViewModelの初期化
        _homeViewModel = State(initialValue: HomeViewModel())
        // 初期タブの設定（デフォルトはカレンダー/時間割: 1）
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 0. ホーム画面（タイムラインと右上の検索）
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: "house.fill")
            }
            .tag(0)

            // 1. カレンダー画面（時間割とオンデマンド）
            NavigationStack {
                // TODO: CalendarView() に置き換える➡︎多分いけた！
                TimetableView()
            }
            .tabItem {
                Label("カレンダー", systemImage: "calendar")
            }
            .tag(1)

            // 2. 通知画面（アラーム機能や通知一覧）
            NavigationStack {
                            // TODO: SearchView() に置き換える
                            Text("検索画面をここに作ります")
                                .navigationTitle("検索")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .tabItem {
                            Label("検索", systemImage: "magnifyingglass")
                        }
                        .tag(2)

            // 3. マイページ画面（プロフィール設定やブックマーク確認）
            NavigationStack {
                // TODO: AccountView() に置き換える
                Text("マイページ画面をここに作ります")
                    .navigationTitle("マイページ")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("アカウント", systemImage: "person.fill")
            }
            .tag(3)
        }
        // 選択されたタブのアイコン色を「うめったー」のメインカラー（えんじ色）に設定
        .tint(Color.umeRed)
    }
}

#Preview {
    MainTabView()
}
