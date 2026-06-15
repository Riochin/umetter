import SwiftUI

struct ProfileSectionView: View {
    let friendsCount: Int
    let postsCount: Int
    var onFriendsTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: "E5E7EB"))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(18)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなた（匿名）")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textDark)
                    Text("学芸学部 情報科学科")
                        .font(.subheadline)
                        .foregroundColor(.textGray)
                    Text("2024年度入学")
                        .font(.caption)
                        .foregroundColor(.textLight)
                }
                Spacer()
            }
            
            Text("よろしくお願いします！アプリ開発の勉強中です📝")
                .font(.subheadline)
                .foregroundColor(.textDark)
                .lineSpacing(4)
            
            HStack(spacing: 16) {
                Button(action: onFriendsTapped) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(friendsCount)").font(.headline).fontWeight(.bold).foregroundColor(.textDark)
                        Text("友達").font(.caption).foregroundColor(.textGray)
                    }
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(postsCount)").font(.headline).fontWeight(.bold).foregroundColor(.textDark)
                    Text("投稿").font(.caption).foregroundColor(.textGray)
                }
            }
            
            Button(action: {}) {
                Text("プロフィールを編集")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.umeRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.umeRed, lineWidth: 1))
            }
        }
        .padding(20)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
