//
//  GameImageAPI.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/08/09.
//

import Foundation

/// ゲーム画像関連のAPIクライアント
final class GameImageAPI {
    static let shared = GameImageAPI()
    private init() {}

    /// サーバーから画像リストを取得
    /// - Returns: Photoモデルの配列
    func fetchImageList() async throws -> [Photo] {
        // アクセストークン取得
        guard let token = try await TokenManager.shared.getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        // APIエンドポイント（適宜変更）
        guard let url = URL(string: "https://rihlar-stage.kokomeow.com/game/image/list") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // API通信
        let (data, _) = try await URLSession.shared.data(for: request)

        // デコード
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Photo].self, from: data)
    }
}
