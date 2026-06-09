//
//  Components.swift
//  Umetter_App
//
//  Created by 渡邊藍 on 2026/06/05.
//

import SwiftUI

// MARK: - Subviews

/// プロフィールセクション
struct ProfileSection: View {
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
            
            // 統計情報
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
                    .foregroundColor(.umePrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.umePrimary, lineWidth: 1))
            }
        }
        .padding(20)
        .background(Color.cardBg)
        .cornerRadius(16)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// 切り替えタブボタン
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 13))
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .umePrimary : .textGray)
                
                Rectangle()
                    .fill(isSelected ? Color.umePrimary : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5, corners: [.topLeft, .topRight])
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// 友達リストの1行
struct FriendRow: View {
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
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

/// 投稿カード
struct PostCard: View {
    @Binding var post: Post // BindingにすることでViewModelと同期
    
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
                    Text(tag).font(.caption).fontWeight(.bold).foregroundColor(.umePrimary)
                }
            }
            
            HStack(spacing: 0) {
                ActionIcon(iconName: "bubble.right", count: nil)
                Spacer()
                Button(action: {
                    post.isLiked.toggle()
                    post.likes += post.isLiked ? 1 : -1
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18)).foregroundColor(post.isLiked ? .umePrimary : .textLight)
                        Text("\(post.likes)")
                            .font(.caption).fontWeight(.bold).foregroundColor(post.isLiked ? .umePrimary : .textLight)
                    }
                }
                Spacer()
                Button(action: { post.isSaved.toggle() }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18)).foregroundColor(post.isSaved ? .umePrimary : .textLight)
                }
                Spacer()
                ActionIcon(iconName: "square.and.arrow.up", count: nil)
            }
            .padding(.top, 4).padding(.horizontal, 8)
        }
        .padding(16)
        .background(Color.cardBg)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ActionIcon: View {
    let iconName: String
    let count: String?
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: iconName).font(.system(size: 18)).foregroundColor(.textLight)
                if let count = count {
                    Text(count).font(.caption).fontWeight(.bold).foregroundColor(.textLight)
                }
            }
        }
    }
}

/// ボトムナビゲーション
struct BottomNavigationBar: View {
    let selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color.borderColor)
            
            HStack {
                NavItem(iconName: "house", isSelected: selectedIndex == 0)
                NavItem(iconName: "magnifyingglass", isSelected: selectedIndex == 1)
                NavItem(iconName: "calendar", isSelected: selectedIndex == 2)
                NavItem(iconName: "bell", isSelected: selectedIndex == 3)
                NavItem(iconName: "person", isSelected: selectedIndex == 4)
            }
            .padding(.top, 12).padding(.bottom, 34).background(Color.umeBg)
        }
    }
}

struct NavItem: View {
    let iconName: String
    let isSelected: Bool
    
    var body: some View {
        Spacer()
        Button(action: {}) {
            Image(systemName: isSelected ? iconName + ".fill" : iconName)
                .font(.system(size: 24)).foregroundColor(isSelected ? .umePrimary : .textLight)
        }
        Spacer()
    }
}

// MARK: - Helpers
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
