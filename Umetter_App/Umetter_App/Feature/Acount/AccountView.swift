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
                        .foregroundColor(.umeRed)
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.umeBackground)
                
                // メインコンテンツ
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // プロフィールカード
                        ProfileSectionView(
                            profile: viewModel.userProfile,
                            friendsCount: viewModel.friendsCount,
                            postsCount: viewModel.postsCount,
                            onFriendsTapped: { viewModel.switchTab(to: 3) },
                            onEditTapped: { viewModel.showingEditProfile = true }
                        )
                        
                        // コンテンツ切り替えタブ
                        HStack(spacing: 0) {
                            TabButtonView(title: "投稿", isSelected: viewModel.selectedTab == 0) { viewModel.switchTab(to: 0) }
                            TabButtonView(title: "いいね", isSelected: viewModel.selectedTab == 1) { viewModel.switchTab(to: 1) }
                            TabButtonView(title: "保存", isSelected: viewModel.selectedTab == 2) { viewModel.switchTab(to: 2) }
                            TabButtonView(title: "友達", isSelected: viewModel.selectedTab == 3) { viewModel.switchTab(to: 3) }
                        }
                        .padding(.bottom, 4)
                        
                        // タブコンテンツ
                        VStack(spacing: 12) {
                            if viewModel.selectedTab == 0 {
                                if viewModel.myPosts.isEmpty {
                                    Text("投稿はありません")
                                        .font(.footnote)
                                        .foregroundColor(.textLight)
                                        .padding(.top, 32)
                                } else {
                                    ForEach(viewModel.myPosts) { post in
                                        PostCardView(
                                            post: post,
                                            onLike: { viewModel.toggleLike(for: post) },
                                            onSave: { viewModel.toggleSave(for: post) }
                                        )
                                    }
                                }
                            } else if viewModel.selectedTab == 1 {
                                // 💡 いいねリストが空のときの表示を追加
                                if viewModel.likedPosts.isEmpty {
                                    Text("いいねした投稿はありません")
                                        .font(.footnote)
                                        .foregroundColor(.textLight)
                                        .padding(.top, 32)
                                } else {
                                    ForEach(viewModel.likedPosts) { post in
                                        PostCardView(
                                            post: post,
                                            onLike: { viewModel.toggleLike(for: post) },
                                            onSave: { viewModel.toggleSave(for: post) }
                                        )
                                    }
                                }
                            } else if viewModel.selectedTab == 2 {
                                // 💡 保存リストが空のときの表示を追加
                                if viewModel.savedPosts.isEmpty {
                                    Text("保存した投稿はありません")
                                        .font(.footnote)
                                        .foregroundColor(.textLight)
                                        .padding(.top, 32)
                                } else {
                                    ForEach(viewModel.savedPosts) { post in
                                        PostCardView(
                                            post: post,
                                            onLike: { viewModel.toggleLike(for: post) },
                                            onSave: { viewModel.toggleSave(for: post) }
                                        )
                                    }
                                }
                            } else if viewModel.selectedTab == 3 {
                                if viewModel.friends.isEmpty {
                                    Text("友達はいません")
                                        .font(.footnote)
                                        .foregroundColor(.textLight)
                                        .padding(.top, 32)
                                } else {
                                    VStack(spacing: 8) {
                                        ForEach($viewModel.friends) { $friend in
                                            FriendRowView(friend: $friend) {
                                                viewModel.toggleFriendStatus(for: friend.id)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 100)
                }
                .background(Color.umeBackground)
            }
            
            // トースト通知
            if viewModel.showToast {
                VStack {
                    Spacer()
                    Text(viewModel.toastMessage)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.textDark.opacity(0.9))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
            }
        }
        .sheet(isPresented: $viewModel.showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
