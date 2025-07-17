//
//  User.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//
import Foundation
// ユーザー情報のモデル定義
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var provCode: String
    var provUID: String

    var iconUrl: URL? {
        URL(string: "https://rihlar-stage.kokomeow.com/auth/assets/\(id).png")
    }

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case name
        case email
        case provCode = "prov_code"
        case provUID = "prov_uid"
    }
}


