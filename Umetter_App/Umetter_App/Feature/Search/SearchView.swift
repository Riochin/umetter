import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. ヘッダー（検索バー）
                headerView
                
                // 2. メインコンテンツ
                ZStack(alignment: .top) {
                    // 👇 背景をホーム画面と同じベージュに変更！
                    Color.umeBackground.ignoresSafeArea()
                    
                    if viewModel.currentViewState == .results {
                        searchResultsView
                    } else if viewModel.currentViewState == .searching && !viewModel.searchText.isEmpty {
                        suggestView
                    } else {
                        searchHistoryView
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color.umeBackground.ignoresSafeArea())
        }
    }

    // MARK: - UI Components
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(.textLight)
                    
                    TextField("#サークル勧誘 やキーワードで検索", text: $viewModel.searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.textDark)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            viewModel.performSearch(query: viewModel.searchText)
                        }
                        .onChange(of: viewModel.searchText) { oldValue, newValue in
                            if newValue.isEmpty {
                                viewModel.currentViewState = .empty
                            } else if viewModel.currentViewState != .results {
                                viewModel.currentViewState = .searching
                            }
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.currentViewState = .empty
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.textLight)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.cardBg)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
                
                if isTextFieldFocused {
                    Button("キャンセル") {
                        isTextFieldFocused = false
                        viewModel.searchText = ""
                        viewModel.currentViewState = .empty
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.textDark)
                    .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider().background(Color.borderColor)
        }
        .background(Color.umeBackground)
    }

    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近の検索")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textDark)
                Spacer()
                if !viewModel.searchHistory.isEmpty {
                    Button("すべて消去") {
                        viewModel.clearHistory()
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.textLight)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            if viewModel.searchHistory.isEmpty {
                Text("検索履歴はありません。")
                    .font(.system(size: 12))
                    .foregroundColor(.textLight)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.searchHistory.enumerated()), id: \.offset) { index, history in
                            HStack(spacing: 6) {
                                Text(history)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.umeRed)
                                    .onTapGesture {
                                        viewModel.performSearch(query: history)
                                        isTextFieldFocused = false
                                    }
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(.textLight)
                                    .padding(2)
                                    .onTapGesture {
                                        viewModel.removeHistoryItem(at: index)
                                    }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.cardBg)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    private var suggestView: some View {
        ScrollView {
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.performSearch(query: viewModel.searchText)
                    isTextFieldFocused = false
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(.umeRed)
                            .frame(width: 32, height: 32)
                            .background(Color.umeRed.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("\"\(viewModel.searchText)\" を検索")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textDark)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                Divider().background(Color.borderColor)
            }
        }
    }

    private var searchResultsView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(title: "話題", isSelected: viewModel.currentTab == .top) {
                    viewModel.currentTab = .top
                }
                TabButton(title: "最新", isSelected: viewModel.currentTab == .latest) {
                    viewModel.currentTab = .latest
                }
            }
            .background(Color.cardBg)
            .overlay(Divider().background(Color.borderColor), alignment: .bottom)
            
            ScrollView {
                if viewModel.searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.textLight.opacity(0.5))
                        Text("該当する投稿が見つかりません。")
                            .font(.system(size: 14))
                            .foregroundColor(.textLight)
                    }
                    .padding(.top, 60)
                } else {
                    // 👇 Dividerを消して、カード同士の隙間(spacing: 12)を空ける！
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults) { post in
                            PostRow(post: post)
                        }
                    }
                    .padding(.vertical, 16) // リスト全体の上下の余白
                }
            }
        }
    }
}

// MARK: - Subviews

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? .textDark : .textLight)
                    .padding(.vertical, 12)
                
                Rectangle()
                    .fill(isSelected ? Color.umeRed : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// 👇 ホーム画面に合わせたカード型デザイン
struct PostRow: View {
    let post: PostModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(post.userName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textDark)
                
                Text(post.timeAgo(from: Date()))
                    .font(.system(size: 12))
                    .foregroundColor(.textLight)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(.textLight)
            }
            
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(.textDark)
                .lineSpacing(4)
            
            if !post.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.umeRed)
                    }
                }
            }
            
            // 👇 アイコンを Spacer() で均等に配置
            HStack {
                Image(systemName: "bubble.right")
                
                Spacer()
                
                HStack(spacing: 4) {
                    // ※HomeViewで使っている UmeIcon があれば、ここで差し替えてもOKです！
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .umeRed : .textLight)
                    Text("\(post.likesCount)")
                }
                
                Spacer()
                
                Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                    .foregroundColor(post.isSaved ? .umeRed : .textLight)
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
            }
            .font(.system(size: 16))
            .foregroundColor(.textLight)
            .padding(.top, 4)
            .padding(.horizontal, 8) // アイコン群の両端に少し余白
        }
        .padding(16)
        .background(Color.cardBg)
        .cornerRadius(16) // 丸みをつける
        .padding(.horizontal, 16) // 画面の端から少し浮かせる
    }
}

#Preview {
    SearchView()
}
