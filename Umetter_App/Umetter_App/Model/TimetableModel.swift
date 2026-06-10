//
//  TimetableModel.swift
//  Umetter_App
//
//  Created by 小宮あかり on 2026/06/05.
//
import SwiftUI

// MARK: - データの型定義
struct TimetableSlot: Identifiable, Equatable {
    let id = UUID()
    var subject: String
    var room: String
    var themeColor: SlotColor
}

enum SlotColor: String, CaseIterable {
    case blue = "ブルー"
    case pink = "ピンク"
    case orange = "オレンジ"
    case green = "グリーン"
    case purple = "パープル"
    
    var background: Color {
        switch self {
        case .blue: return Color(red: 0.77, green: 0.87, blue: 0.96)
        case .pink: return Color(red: 0.96, green: 0.76, blue: 0.83)
        case .orange: return Color(red: 0.98, green: 0.85, blue: 0.74)
        case .green: return Color(red: 0.85, green: 0.92, blue: 0.76)
        case .purple: return Color(red: 0.90, green: 0.80, blue: 0.95)
        }
    }
    
    var text: Color {
        return Color(red: 0.2, green: 0.2, blue: 0.2)
    }
}
