//
//  AccountView.swift
//  Umetter_App
//
//  Created by 渡邊藍 on 2026/06/05.
//
import SwiftUI

// MARK: - Views (Main)
struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Text("マイページ")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.umePrimary)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.textLight)
                            .font(.system(size: 22))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.umeBg)
                
                // メインコンテンツ
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // プロフィールカード
                        ProfileSection(
                            friendsCount: viewModel.friendsCount,
                            postsCount: viewModel.postsCount,
                            onFriendsTapped: { viewModel.switchTab(to: 3) }
                        )
                        
                        // コンテンツ切り替えタブ
                        HStack(spacing: 0) {
                            TabButton(title: "投稿", isSelected: viewModel.selectedTab == 0) { viewModel.switchTab(to: 0) }
                            TabButton(title: "いいね", isSelected: viewModel.selectedTab == 1) { viewModel.switchTab(to: 1) }
                            TabButton(title: "保存", isSelected: viewModel.selectedTab == 2) { viewModel.switchTab(to: 2) }
                            TabButton(title: "友達", isSelected: viewModel.selectedTab == 3) { viewModel.switchTab(to: 3) }
                        }
                        .padding(.bottom, 4)
                        
                        // タブコンテンツ
                        VStack(spacing: 12) {
                            if viewModel.selectedTab == 0 {
                                ForEach($viewModel.myPosts) { $post in
                                    PostCard(post: $post)
                                }
                            } else if viewModel.selectedTab == 1 {
                                ForEach($viewModel.likedPosts) { $post in
                                    PostCard(post: $post)
                                }
                            } else if viewModel.selectedTab == 2 {
                                ForEach($viewModel.savedPosts) { $post in
                                    PostCard(post: $post)
                                }
                            } else if viewModel.selectedTab == 3 {
                                VStack(spacing: 8) {
                                    ForEach($viewModel.friends) { $friend in
                                        FriendRow(friend: $friend) {
                                            viewModel.toggleFriendStatus(for: friend.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 100) // ボトムナビゲーション＆トースト用余白
                }
                .background(Color.umeBg)
            }
            
            // トースト通知（ZStackの前面に配置）
            if viewModel.showToast {
                VStack {
                    Spacer()
                    Text(viewModel.toastMessage)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "1F2937").opacity(0.9))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                        .padding(.bottom, 100) // ボトムナビゲーションの上に表示
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
            }
        }
        /*.overlay(
            BottomNavigationBar(selectedIndex: 4),
            alignment: .bottom
        )*/
         
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
