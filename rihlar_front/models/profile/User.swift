//
//  User.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//
import Foundation

// APIのレスポンスに対応するユーザー情報モデル
struct User: Codable, Identifiable {
    let id: String              // ユーザーid
    var name: String            // ユーザー名 (変更可能にするためvarに変更)
    let email: String?          // メールアドレス（フロント側では使い道ないかも）
    let provCode: String?       // 認証プロバイダ（今回はgoogle）
    let provUid: String?        // プロバイダ側のユーザーid
    var iconUrl: URL?           // ユーザーアイコンのURL (算出プロパティから保存プロパティに変更)

    // APIのキーとswiftのプロパティのマッピング（snake_case→camelCase）
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case name
        case email
        case provCode = "prov_code"
        case provUid = "prov_uid"
        case iconUrl = "icon_url" // APIからのレスポンスに"icon_url"が含まれる場合
    }
    
    // initをカスタマイズして、APIレスポンスにicon_urlが含まれない場合のデフォルト値を設定
    // または、APIレスポンスに必ずicon_urlが含まれるようにバックエンドを修正
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.provCode = try container.decodeIfPresent(String.self, forKey: .provCode)
        self.provUid = try container.decodeIfPresent(String.self, forKey: .provUid)
        
        // iconUrlがAPIレスポンスに直接含まれる場合
        if let iconUrlString = try container.decodeIfPresent(String.self, forKey: .iconUrl) {
            self.iconUrl = URL(string: iconUrlString)
        } else {
            // APIレスポンスにicon_urlがない場合のデフォルトURL
            self.iconUrl = URL(string: "https://rihlar.kokomeow.com/auth/assets/\(id).png")
        }
    }
    
    // プログラマティックにUserを生成するためのイニシャライザ（テストやモック用）
    init(id: String, name: String, email: String?, provCode: String?, provUid: String?, iconUrl: URL?) {
        self.id = id
        self.name = name
        self.email = email
        self.provCode = provCode
        self.provUid = provUid
        self.iconUrl = iconUrl
    }
}


