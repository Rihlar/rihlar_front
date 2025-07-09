//
//  User.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//
import Foundation
// APIのレスポンスに対応するユーザー情報モデル
struct User:Codable, Identifiable{
    let id: String              // ユーザーid
    let  name: String           // ユーザー名
    let email: String?          // メールアドレス（フロント側では使い道ないかも）
    let provCode: String?       // 認証プロバイダ（今回はgoogle）
    let provUid: String?        // プロバイダ側のユーザーid
    
    // APIのキーとswiftのプロアティのマッピング（snake_case→camelCase）
    enum CodengKeys: String, CodingKey {
        case id = "user_id"
        case name
        case email
        case provCode = "prov_code"
        case provUid = "prov_uid"
    }
    
    
    // ユーザーのアイコン（バックエンドでユーザーIDに応じて作成される）
    var iconUrl:URL?{
        URL(string: "https://rihlar.kokomeow.com/auth/assets/\(id).png")
    }
}
