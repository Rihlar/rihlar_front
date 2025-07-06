//
//  friend_tab.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/06.
//

import SwiftUI
// タブの状態を定義
enum FriendTab: String, CaseIterable {
    case friends = "フレンド"
    case requesting = "申請中"
    case pending = "承認"
}
