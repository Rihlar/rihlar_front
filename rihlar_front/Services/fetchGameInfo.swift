//
//  fetchGameInfo.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import Foundation

// 自分が参加しているゲーム情報を取得する関数
func fetchGameInfo(token: String) async throws -> GameData {
    let url = APIConfig.gameUserInfoURL()
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(token, forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    print(String(data: data, encoding: .utf8) ?? "Invalid data")

    // ルートのGameInfoResponseでデコード
    let response = try JSONDecoder().decode(GameInfoResponse.self, from: data)
    return response.data
}



// レスポンスモデル
struct GameInfoResponse: Codable {
    let data: GameData

    enum CodingKeys: String, CodingKey {
        case data = "Data"  // APIレスポンスの大文字「Data」にマッピング
    }
}

struct GameData: Codable {
    let isAdminJoined: Bool?
    let admin: AdminGameInfo?
    let system: SystemGameInfo

    enum CodingKeys: String, CodingKey {
        case isAdminJoined = "IsAdminJoined"
        case admin = "admin"        // もしAPIが大文字ならここも修正
        case system = "system"      // 同上
    }
}


struct AdminGameInfo: Codable {
    let gameID: String

    enum CodingKeys: String, CodingKey {
        case gameID = "GameID"
    }
}

struct SystemGameInfo: Codable {
    let gameID: String

    enum CodingKeys: String, CodingKey {
        case gameID = "GameID"
    }
}
