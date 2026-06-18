import SwiftUI

struct NewPostView: View {
    let post: PostModel
    @ObservedObject var viewModel: HomeViewModel
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("匿名")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(post.timeAgo(from: now))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }

            Text(post.body)
                .font(.subheadline)
                .foregroundColor(.primary)

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

            if post.attachmentUrl != nil {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 160)
                    .cornerRadius(10)
                    .overlay(Text("画像プレビュー").foregroundColor(.gray))
            }

            HStack {
                Button(action: {}) { Image(systemName: "message").foregroundColor(.gray) }
                Spacer()

                Button(action: { viewModel.toggleLike(for: post) }) {
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

                Button(action: { viewModel.toggleSave(for: post) }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(post.isSaved ? .umeRed : .gray)
                }

                Spacer()
                Button(action: {}) { Image(systemName: "square.and.arrow.up").foregroundColor(.gray) }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 12)
    }
}
