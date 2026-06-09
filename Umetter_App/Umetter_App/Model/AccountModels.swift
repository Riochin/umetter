//
//  Models.swift
//  Umetter_App
//
//  Created by 渡邊藍 on 2026/06/05.
//
import SwiftUI

// MARK: - Models
struct Post: Identifiable {
    let id = UUID()
    let author: String
    let timeAgo: String
    let content: String
    let tags: [String]
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let department: String
    var isFriend: Bool
    let iconColor: Color
}
