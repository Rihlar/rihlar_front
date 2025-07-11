//
//  UserProfile.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/10.
//

// APIのレスポンスに合わせて定義する
// 例：ユーザー名とアイコンURLを取得
struct UserProfile: Decodable {
    let user_id: String
    let name: String
    let record_id: String
    let comment: String
    let latitude: Int
    let longitude: Int
    let size: Int
    let region_id: String
    let system_game_id: String
    let admin_game_id: String
}
