import SwiftUI

struct PostCardView: View {
    let post: PostModel
    let now: Date = Date()

    var onLike: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("匿名").font(.subheadline).fontWeight(.bold).foregroundColor(.textDark)
                Text(post.timeAgo(from: now)).font(.caption).foregroundColor(.textLight)
                Spacer()
                Button(action: {}) { Image(systemName: "ellipsis").foregroundColor(.textLight) }
            }

            Text(post.body).font(.subheadline).foregroundColor(.textDark).lineSpacing(4)

            if !post.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag).font(.caption).fontWeight(.bold).foregroundColor(.umeRed)
                    }
                }
            }

            HStack(spacing: 0) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 18)).foregroundColor(.textLight)
                Spacer()
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        UmeIcon(isLiked: post.isLiked)
                        Text("\(post.likesCount)")
                            .font(.caption).fontWeight(.bold).foregroundColor(post.isLiked ? .umeRed : .textLight)
                    }
                }
                Spacer()
                Button(action: onSave) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18)).foregroundColor(post.isSaved ? .umeRed : .textLight)
                }
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18)).foregroundColor(.textLight)
            }
            .padding(.top, 4).padding(.horizontal, 8)
        }
        .padding(16)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
