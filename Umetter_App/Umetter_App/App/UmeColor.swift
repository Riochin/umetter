import SwiftUI

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Theme Colors
extension Color {
    // Brand Colors
    static let umeRed = Color(hex: "8B1E38")
    static let umeBackground = Color(hex: "F8F4F0")
    
    // UI Colors
    static let umePrimaryHover = Color(hex: "6C152A")
    static let textDark = Color(hex: "1F2937")
    static let textGray = Color(hex: "4B5563")
    static let textLight = Color(hex: "9CA3AF")
    static let borderColor = Color(hex: "E5E7EB")
    static let cardBg = Color.white
    
    // Accent Colors
    static let cheekPink = Color(hex: "FF9CB5")
    static let umeYellow = Color(hex: "FFB300")
}
