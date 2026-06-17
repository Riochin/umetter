//
//  UmeFlowerView.swift
//  Umetter_App
//
//  Created by 悠 on 2026/06/05.
//
import SwiftUI

/// 黄金比ふっくら梅の花ビュー
struct UmeFlowerView: View {
    var size: CGFloat = 112
    
    var body: some View {
        ZStack {
            // 白い花びらベース
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.3515, height: size * 0.3515)
                    .offset(y: -size * 0.1562)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.2539, height: size * 0.2539)
            
            // チークグラデーション
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [Color.cheekPink.opacity(0.6), Color.cheekPink.opacity(0.2), Color.white.opacity(0)]), center: .center, startRadius: 0, endRadius: size * 0.22)
                )
                .frame(width: size * 0.44, height: size * 0.44)
            
            // しべ
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color.umeYellow)
                    .frame(width: size * 0.035, height: size * 0.035)
                    .offset(y: -size * 0.08)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            
            // 中心
            Circle()
                .fill(Color(hex: "E24A6D"))
                .frame(width: size * 0.05, height: size * 0.05)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.022, height: size * 0.022)
        }
        .compositingGroup()
    }
}

// コンポーネント単体のプレビュー
struct UmeFlowerView_Previews: PreviewProvider {
    static var previews: some View {
        UmeFlowerView()
            .padding()
            .background(Color.warmBg)
            .previewLayout(.sizeThatFits)
    }
}
