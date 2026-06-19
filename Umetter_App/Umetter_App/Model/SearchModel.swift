//
//  SearchModel.swift
//  Umetter_App
//
//  Created by 小宮あかり on 2026/06/19.
//
import Foundation

// MARK: - Search Models

/// 検索画面の現在の状態を表すルール
enum SearchViewState {
    case empty      // 何も入力されていない（履歴を表示）
    case searching  // 検索中・入力中
    case results    // 検索結果を表示
}

/// 検索結果のタブを表すルール
enum SearchTab {
    case top        // トップ（いいね順）
    case latest     // 最新（時間順）
}
