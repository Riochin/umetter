import SwiftUI

struct HomeView: View {
    // ViewModelを保持
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingNewPost = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // 背景色
                Color.umeBackground.ignoresSafeArea()
                
                ScrollView {
                    // 休講情報バー
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("【重要】休講情報: SitesGoogleLink...")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.umeRed)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 238/255, green: 220/255, blue: 211/255).opacity(0.5))
                    .overlay(
                        VStack {
                            Divider()
                            Spacer()
                            Divider()
                        }
                    )
                    
                    // タイムライン
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.posts) { post in
                            NewPostVeiw(post: post, viewModel: viewModel)
                        }
                    }
                    .padding(.top, 8)
                    // ボトムナビがある想定での余白
                    .padding(.bottom, 100)
                }
                
                // フローティングアクションボタン (FAB)
                Button(action: { showingNewPost = true }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.umeRed)
                        .clipShape(Circle())
                        .shadow(color: Color.umeRed.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24) // 実際のボトムナビの高さに合わせて調整
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        UmeIcon(isLiked: true)
                            .frame(width: 18, height: 18)
                        Text("うめったー")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.umeRed)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                // 投稿画面のモック（ボトムシート）
                Text("ここに投稿画面を作ります")
                    .presentationDetents([.fraction(0.9)])
            }
        }
    }
}

// プレビュー表示用
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

