//
//  SearchView.swift
//  Umetter_App
//
//  Created by 小宮あかり on 2026/06/17.
//

import SwiftUI

// MARK: - Custom Colors
extension Color {
    // hexエラーを避けるため、RGBで直接色を指定しています
    static let primaryRed = Color(red: 139/255, green: 30/255, blue: 56/255)
    static let bgGray = Color(red: 248/255, green: 244/255, blue: 240/255)
}

// MARK: - Search View
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. ヘッダー（検索バー）
            searchBar
            
            // 2. メインコンテンツ領域
            ZStack(alignment: .top) {
                // ★ 背景を真っ白からアプリ共通のベージュに変更
                Color.bgGray.ignoresSafeArea()
                
                switch viewModel.currentViewState {
                case .history:
                    historySection
                case .suggesting:
                    suggestSection
                case .results:
                    resultsSection
                }
            }
        }
        // ここも背景色をベージュに指定
        .background(Color.bgGray.ignoresSafeArea())
    }
    
    // MARK: - UI Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("#サークル勧誘 やキーワードで検索", text: $viewModel.searchText)
                .onSubmit {
                    viewModel.performSearch(query: viewModel.searchText)
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        // 両端と上下に余白を持たせて、ベージュ背景に浮かせる
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近の検索")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                if !viewModel.searchHistory.isEmpty {
                    Button("すべて消去") {
                        viewModel.clearAllHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            if viewModel.searchHistory.isEmpty {
                Text("検索履歴はありません。")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.searchHistory, id: \.self) { historyItem in
                            HStack(spacing: 6) {
                                Text(historyItem)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryRed)
                                    .onTapGesture {
                                        viewModel.performSearch(query: historyItem)
                                    }
                                
                                Button(action: {
                                    viewModel.removeHistoryItem(historyItem)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
        }
    }
    
    private var suggestSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    viewModel.performSearch(query: viewModel.searchText)
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text("\"\(viewModel.searchText)\" を検索")
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                }
                
                Divider()
                
                ForEach(viewModel.suggestedTags, id: \.self) { tag in
                    Button(action: {
                        viewModel.performSearch(query: tag)
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryRed.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "number")
                                    .foregroundColor(.primaryRed)
                                    .font(.caption)
                            }
                            Text(tag)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                    }
                    Divider()
                }
            }
        }
    }
    
    private var resultsSection: some View {
        VStack(spacing: 0) {
            // タブ部分は白背景でスッキリと
            HStack {
                TabButton(title: "話題", isSelected: viewModel.currentTab == .top) {
                    viewModel.switchTab(to: .top)
                }
                TabButton(title: "最新", isSelected: viewModel.currentTab == .latest) {
                    viewModel.switchTab(to: .latest)
                }
            }
            .background(Color.white)
            
            ScrollView {
                if viewModel.searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.top, 60)
                        Text("該当する投稿が見つかりません。")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        // 少し上部に余白を空ける
                        Spacer().frame(height: 4)
                        
                        ForEach(viewModel.searchResults) { post in
                            PostRow(post: post)
                        }
                        
                        // 下部ナビゲーションに隠れないように余白
                        Spacer().frame(height: 20)
                    }
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
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .black : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.primaryRed : Color.clear)
                    .frame(height: 3)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

// ★ ホーム画面の投稿デザインに合わせた角丸カード
struct PostRow: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー部分（アイコンと名前）
            HStack(spacing: 8) {
                // アイコンの仮置き
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                // 右上の「…」ボタン
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            
            Text(post.content)
                .font(.subheadline)
                .lineSpacing(4)
            
            HStack {
                ForEach(post.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryRed)
                }
            }
            
            // アクションボタン（ホーム画面のスクリーンショットに寄せています）
            HStack(spacing: 32) {
                Image(systemName: "bubble.right")
                
                HStack(spacing: 4) {
                    Image(systemName: "rosette") // お花の代わり
                    Text("\(post.likes)")
                }
                
                Image(systemName: "bookmark")
                Image(systemName: "square.and.arrow.up")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.top, 4)
        }
        .padding()
        // カード自体の背景を白にし、角を丸くする
        .background(Color.white)
        .cornerRadius(20)
        // 画面の両端から少し内側に配置する
        .padding(.horizontal)
    }
}

#Preview {
    SearchView()
}
