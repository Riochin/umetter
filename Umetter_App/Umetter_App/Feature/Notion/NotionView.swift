import SwiftUI

struct NotionView: View {
    @ObservedObject var viewModel: NotionViewModel
        @Environment(\.dismiss) private var dismiss
        
        private let umeRed = Color(red: 139/255, green: 30/255, blue: 56/255)
        private let bgColor = Color(red: 248/255, green: 244/255, blue: 240/255)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ヘッダー
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "bell")
                        .foregroundColor(umeRed)
                    
                    Text("通知")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    // 設定画面を作るならここに処理を書く
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(bgColor)
            
            HStack(spacing: 0) {
                tabButton(title: "すべて", tab: .all)
                tabButton(title: "教室情報", tab: .classInfo)
                tabButton(title: "休講情報", tab: .cancellation)
            }
            .background(bgColor)
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredNotifications) { item in
                        notificationRow(item: item)
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color.white)
        }
        .background(bgColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func tabButton(title: String, tab: NotificationTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedTab = tab
            }
        }) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.selectedTab == tab ? .primary : .gray)
                
                Rectangle()
                    .fill(viewModel.selectedTab == tab ? umeRed : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .padding(.top, 10)
        }
    }
    
    private func notificationRow(item: NotionItemModel) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                
                ZStack {
                    Circle()
                        .fill(item.isPast ? Color(red: 243/255, green: 244/255, blue: 246/255) : item.type.iconBackground)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: item.type.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(item.isPast ? .gray : item.type.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(item.isPast ? .gray : .primary)
                        
                        Spacer()
                        
                        TimelineView(.periodic(from: Date(), by: 1)) { context in
                            Text(item.timeAgo(now: context.date))
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(item.message)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255))
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture {
                print("\(item.title) がタップされました")
            }
            
            Divider()
        }
        .opacity(item.isPast ? 0.8 : 1.0)
    }
}
