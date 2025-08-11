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
    let circleId: String?   // circle_id (円に紐づく)
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case theme
        case shared
        case gameId = "game_id"
        case url = "image_url"
        case circleId = "circle_id"
    }
}

// 写真一覧取得用のモデル定義
struct PhotoListResponse: Codable {
    let Data: [PhotoSummary]
}

struct PhotoSummary: Codable, Identifiable {
    let id: String
    let theme: String?
    let timestamp: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "circleId"
        case theme
        case timestamp
    }
}

// MARK: - 詳細画像情報取得用モデル
// /game/circle/image/{circleId} APIのレスポンス用
struct PhotoDetail: Codable {
    let image_id: String      // 画像ID
    let user_id: String       // ユーザーID
    let created_at: String    // 投稿日時 (ISO8601形式の文字列)
    let theme: String?        // テーマ
    let shared: Bool          // 共有状態
    let game_id: String       // ゲームID
    let image_url: String     // 画像URL
    
    enum CodingKeys: String, CodingKey {
        case image_id
        case user_id
        case created_at
        case theme
        case shared
        case game_id
        case image_url
    }
}
