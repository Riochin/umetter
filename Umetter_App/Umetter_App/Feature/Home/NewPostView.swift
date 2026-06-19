import SwiftUI

struct NewPostView: View {
    let post: PostModel
    @ObservedObject var viewModel: HomeViewModel
    let now: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // ヘッダー（名前・時間・メニュー）
            HStack {
                Text(post.userName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(post.timeAgo(from: now))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // ブロック・通報メニュー
                Menu {
                    Button(role: .destructive, action: {
                        // TODO: ブロック処理
                    }) {
                        Label("ブロック", systemImage: "person.crop.circle.badge.xmark")
                    }
                    
                    Button(role: .destructive, action: {
                        // TODO: 通報処理
                    }) {
                        Label("通報", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(4)
                }
            }
            
            // 本文
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // タグ
            if !post.tags.isEmpty {
                HStack {
                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.umeRed)
                    }
                }
            }
            
            // 画像プレビュー（仮）
            if post.imageUrl != nil {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 160)
                    .cornerRadius(10)
                    .overlay(
                        Text("画像プレビュー")
                            .foregroundColor(.gray)
                    )
            }
            
            // アクションボタン
            HStack {
                Button(action: {
                    // TODO: コメント処理
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 梅いいねボタン
                Button(action: {
                    viewModel.toggleLike(for: post)
                }) {
                    HStack(spacing: 4) {
                        UmeIcon(isLiked: post.isLiked)
                        
                        if post.likesCount > 0 {
                            Text("\(post.likesCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(post.isLiked ? .umeRed : .gray)
                        }
                    }
                }
                
                Spacer()
                
                // ブックマークボタン
                Button(action: {
                    viewModel.toggleSave(for: post)
                }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(post.isSaved ? .umeRed : .gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
        .padding(.horizontal, 12)
    }
}
