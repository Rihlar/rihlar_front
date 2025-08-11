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
    
    /// サーバーから画像リストを取得する非同期関数
    /// - Returns: Photoモデルの配列
    func fetchImageList() async throws -> [PhotoSummary] {
        // アクセストークンを取得（認証が必要）
        guard let token = try await TokenManager.shared.getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // APIのURLを生成
        guard let url = URL(string: "https://rihlar-stage.kokomeow.com/game/image/list") else {
            throw URLError(.badURL)
        }
        
        // GETリクエストを作成し、AuthorizationヘッダーにBearerトークンをセット
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        // URLSessionを使って非同期にデータを取得
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // JSONのデコード準備
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601  // 日付をISO8601形式でデコード
        
        // APIレスポンスは辞書形式でDataという配列を含むため、
        // まずレスポンス用の構造体PhotoListResponseにデコード
        let response = try decoder.decode(PhotoListResponse.self, from: data)
        
        // 解析した配列を返す
        return response.Data
    }
    /// circleIdを使って詳細画像情報を取得する非同期関数
    /// - Parameter circleId: 画像詳細を取得したいcircleId
    /// - Returns: PhotoDetail型の詳細情報
    func fetchPhotoDetail(circleId: String) async throws -> PhotoDetail {
        // アクセストークンを取得（認証が必要）
        guard let token = try await TokenManager.shared.getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // circleIdを使って詳細APIのURLを生成
        guard let url = URL(string: "https://rihlar-stage.kokomeow.com/game/circle/image/\(circleId)") else {
            throw URLError(.badURL)
        }
        
        // GETリクエストを作成し、AuthorizationヘッダーにBearerトークンをセット
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        // URLSessionを使って非同期にデータを取得
        let (data, _) = try await URLSession.shared.data(for: request)

        // JSONのデコード準備
        let decoder = JSONDecoder()

        // 詳細APIは日付文字列なのでデコードはデフォルト（必要に応じて変換はViewModelで）
        let detail = try decoder.decode(PhotoDetail.self, from: data)
        
        return detail
    }
}

