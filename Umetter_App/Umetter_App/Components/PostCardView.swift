import SwiftUI

struct PostCardView: View {
    @Binding var post: AccountPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.author).font(.subheadline).fontWeight(.bold).foregroundColor(.textDark)
                Text(post.timeAgo).font(.caption).foregroundColor(.textLight)
                Spacer()
                Button(action: {}) { Image(systemName: "ellipsis").foregroundColor(.textLight) }
            }
            
            Text(post.content).font(.subheadline).foregroundColor(.textDark).lineSpacing(4)
            
            HStack(spacing: 8) {
                ForEach(post.tags, id: \.self) { tag in
                    Text(tag).font(.caption).fontWeight(.bold).foregroundColor(.umeRed)
                }
            }
            
            HStack(spacing: 0) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 18)).foregroundColor(.textLight)
                Spacer()
                Button(action: {
                    post.isLiked.toggle()
                    post.likes += post.isLiked ? 1 : -1
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18)).foregroundColor(post.isLiked ? .umeRed : .textLight)
                        Text("\(post.likes)")
                            .font(.caption).fontWeight(.bold).foregroundColor(post.isLiked ? .umeRed : .textLight)
                    }
                }
                Spacer()
                Button(action: { post.isSaved.toggle() }) {
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
