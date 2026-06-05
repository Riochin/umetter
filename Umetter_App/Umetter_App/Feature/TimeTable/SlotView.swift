import SwiftUI

struct SlotView: View {
    var slot: TimetableSlot?
    var isOndemand: Bool
    var showPeriod6: Bool // 6限表示中かどうかの判定
    var action: () -> Void
    
    var body: some View {
        
        // 高さを動的に計算（オンデマンド: 45, 6限あり: 65, 6限なし: 85）
        let slotHeight: CGFloat = isOndemand ? 45 : (showPeriod6 ? 65 : 85)
        
        Button(action: action) {
            if let slot = slot {
                VStack {
                    Spacer()
                    Text(slot.subject)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(slot.themeColor.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(isOndemand ? 2 : 3)
                        .padding(.horizontal, 2)
                    
                    Spacer()
                    
                    if !isOndemand && !slot.room.isEmpty {
                        Text(slot.room)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(slot.themeColor.text.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Capsule())
                            .padding(.bottom, 6)
                    }
                }
                // 👇 ここを slotHeight に変更！
                .frame(maxWidth: .infinity, minHeight: slotHeight, maxHeight: .infinity)
                .background(slot.themeColor.background)
                .cornerRadius(12)
                
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: isOndemand ? [4] : []))
                            .foregroundColor(Color.gray.opacity(0.3))
                    )
                    // 👇 空きコマも slotHeight に変更！
                    .frame(maxWidth: .infinity, minHeight: slotHeight, maxHeight: .infinity)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.4))
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - プレビュー用 (XcodeのCanvasで確認するためのコード)
struct SlotView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            // 1. 通常のコマのプレビュー
            SlotView(
                slot: TimetableSlot(subject: "社会学概論", room: "1203", themeColor: .blue),
                isOndemand: false,
                showPeriod6: false, // 👈 追加！
                action: {}
            )
            .frame(width: 60) // 高さは自動計算されるので width だけでOK
            
            // 2. オンデマンドのプレビュー
            SlotView(
                slot: TimetableSlot(subject: "情報倫理", room: "", themeColor: .green),
                isOndemand: true,
                showPeriod6: false, // 👈 追加！
                action: {}
            )
            .frame(width: 60)
            
            // 3. 空きコマのプレビュー
            SlotView(
                slot: nil,
                isOndemand: false,
                showPeriod6: false, // 👈 追加！
                action: {}
            )
            .frame(width: 60)
        }
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        .previewLayout(.sizeThatFits)
    }
}
