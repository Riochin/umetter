import SwiftUI

struct FriendRowView: View {
    @Binding var friend: Friend
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(friend.iconColor)
                .frame(width: 48, height: 48)
                .overlay(Image(systemName: "person.fill").foregroundColor(.white).font(.system(size: 20)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.textDark).lineLimit(1)
                Text(friend.department)
                    .font(.caption).foregroundColor(.textGray).lineLimit(1)
            }
            
            Spacer()
            
            // 友達追加ボタン（フィードバックに基づき、一旦保留のためコメントアウト）
            /*
            Button(action: onToggle) {
                Text(friend.isFriend ? "友達" : "追加")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(friend.isFriend ? .textGray : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(friend.isFriend ? Color.clear : Color.umePrimary)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(friend.isFriend ? Color.borderColor : Color.umePrimary, lineWidth: 1))
            }
            */
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
