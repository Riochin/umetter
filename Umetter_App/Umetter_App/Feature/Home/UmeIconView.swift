import SwiftUI

// 梅の花びらの形
struct UmeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // 花びらを少しふっくらと重なりを多くして可愛くする
        let radius = rect.width / 3.2
        
        for i in 0..<5 {
            let angle = CGFloat(i) * (2 * .pi / 5) - .pi / 2
            let cx = center.x + radius * cos(angle)
            let cy = center.y + radius * sin(angle)
            let petalRect = CGRect(x: cx - radius, y: cy - radius, width: radius * 2, height: radius * 2)
            path.addEllipse(in: petalRect)
        }
        return path
    }
}

// 梅のいいねアイコン本体
struct UmeIcon: View {
    var isLiked: Bool
    
    var body: some View {
        ZStack {
            // 重なる線がキモくなる原因だった stroke をやめ、
            // OFFの時は「薄いグレー」のシルエット（塗りつぶし）にして可愛く修正
            UmeShape()
                .fill(isLiked ? Color.umeRed : Color.gray.opacity(0.3))
            
            // 真ん中のおしべ（背景色で丸くくり抜いたように見せる）
            Circle()
                .fill(Color.umeBackground)
                .frame(width: 6, height: 6) // アイコンサイズに合わせておしべも小さく調整
        }
        .frame(width: 20, height: 20) // アイコン全体を小さくして数字と被らないように調整
        // いいねを押した時の弾けるアニメーション
        .scaleEffect(isLiked ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isLiked)
    }
}
