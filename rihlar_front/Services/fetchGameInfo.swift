//
//  fetchGameInfo.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import Foundation
// 自分が参加しているゲーム情報を取得する関数
func fetchGameInfo(token: String) async throws -> GameData {
    let url = URL(string: "https://rihlar-stage.kokomeow.com/game/info/self")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(token, forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let decoded = try JSONDecoder().decode(GameInfoResponse.self, from: data)
    return decoded.data
}

// レスポンスモデル
struct GameInfoResponse: Codable {
    let data: GameData
    enum CodingKeys: String, CodingKey { case data = "Data" }
}

struct GameData: Codable {
    let isAdminJoined: Bool
    let admin: AdminGameInfo?
    let system: SystemGameInfo
}

struct AdminGameInfo: Codable {
    let gameID: String
    enum CodingKeys: String, CodingKey { case gameID = "GameID" }
}

struct SystemGameInfo: Codable {
    let gameID: String
    enum CodingKeys: String, CodingKey { case gameID = "GameID" }
}
