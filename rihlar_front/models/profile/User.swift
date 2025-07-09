//
//  User.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//
import Foundation
// ユーザー情報のモデル定義
struct User:Codable, Identifiable{
    let id:String   // ユーザーid
    var name:String // ユーザー名
    
    // ユーザーのアイコン
    var iconUrl:URL?{
        URL(string: "https://rihlar.kokomeow.com/auth/assets/\(id).png")
    }
}
