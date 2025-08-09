//
//  Photo.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// 写真情報のモデル定義
struct Photo: Codable, Identifiable {
    let id: String          // imgID
    let userId: String      // userID
    let createdAt: Date     // 投稿した日時
    let theme: String?      // 写真のテーマ
    let shared: Bool        // 共有するかどうか
    let gameId: String      // gameID
    let url: String         // 写真のurl
}

