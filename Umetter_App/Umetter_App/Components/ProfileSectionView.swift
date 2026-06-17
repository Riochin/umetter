import SwiftUI

struct ProfileSectionView: View {
    let profile: UserProfile
    
    let friendsCount: Int
    let postsCount: Int
    var onFriendsTapped: () -> Void
    var onEditTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(profile.iconColor)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(18)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // 名前
                    if profile.name.isEmpty {
                        Text("名前未設定")
                            .font(.title3)
                            .foregroundColor(.textLight)
                    } else {
                        Text(profile.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.textDark)
                    }
                    
                    // 学部
                    if profile.department.isEmpty {
                        Text("学部・学科未設定")
                            .font(.subheadline)
                            .foregroundColor(.textLight)
                    } else {
                        Text(profile.department)
                            .font(.subheadline)
                            .foregroundColor(.textGray)
                    }
                    
                    // 入学年度
                    if profile.enrollmentYear.isEmpty {
                        Text("入学年度未設定")
                            .font(.caption)
                            .foregroundColor(.textLight)
                    } else {
                        Text(profile.enrollmentYear)
                            .font(.caption)
                            .foregroundColor(.textLight)
                    }
                }
                Spacer()
            }
            
            // 自己紹介
            if profile.bio.isEmpty {
                Text("自己紹介はまだ設定されていません。")
                    .font(.subheadline)
                    .foregroundColor(.textLight)
                    .lineSpacing(4)
            } else {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundColor(.textDark)
                    .lineSpacing(4)
            }
            
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
            
            Button(action: onEditTapped) { // 💡 アクションをセット
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
