//
//  RealGameService.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation
import Combine

//    責務：実際のバックエンドから JSON をフェッチ。
//    注意点：URL やリクエストヘッダ、エラー処理は適宜拡張。
/// 本番 API 叩く実装
class RealGameService: GameServiceProtocol {
    func fetchGame(id: String) -> AnyPublisher<GameResponse.Game, Error> {
//        1. path の組み立て
        let path = APIConfig.gameInformation
        let fullURL = APIConfig.stagingBaseURL.appendingPathComponent(path)
        
        return Deferred {
            Future<GameResponse.Game, Error> { promise in
                // Task を使って async/await の呼び出しをラップ
                Task {
                    do {
                        // ① トークンを非同期に取得
                        guard let token = try await TokenManager.shared.getAccessToken() else {
                            throw URLError(.userAuthenticationRequired)
                        }

                        // ② リクエスト組み立て
                        var request = URLRequest(url: fullURL)
                        request.httpMethod = "GET"
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                        print("トークン確認\(token)")
                        // ③ URLSession の async API で呼び出し
                        let (data, response) = try await URLSession.shared.data(for: request)
                        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                            throw URLError(.badServerResponse)
                        }
                        
                        if let jsonText = String(data: data, encoding: .utf8) {
                            print("📦 gameデータ取得のレスポンスJSON文字列:")
                            print(jsonText)
                        }

                        // ④ デコードして成功を返す
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let wrapper = try decoder.decode(GameResponse.self, from: data)
                        promise(.success(wrapper.data))

                    } catch {
                        // ⑤ エラーを返す
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func getTop3CircleRanking(for gameID: String, userID: String) async throws -> [String: TeamCirclesEntity] {
        // 1. path の組み立て
        let path = APIConfig.top3CirclesRankingEndpoint.replacingOccurrences(of: "{gameId}", with: gameID)
        let fullURL = APIConfig.stagingBaseURL.appendingPathComponent(path)
        
        // 2. URLRequest の生成
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        
        // 3. トークン取得
        guard let token = try await TokenManager.shared.getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // 4. 標準ヘッダー設定
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 5. ヘッダー情報にuserIDを追加
        request.setValue(userID, forHTTPHeaderField: "UserID")
        
        // 6. 非同期リクエスト実行
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 7. HTTPレスポンスのステータスコードチェック
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        // 8. デバッグ用JSONログ出力（オプション）
        if let jsonString = String(data: data, encoding: .utf8) {
            // print("📦 トップ3円のレスポンスJSON文字列:")
            // print(jsonString)
        }
        
        // 9. JSONデコード
        let decoder = JSONDecoder()
        let outerResponse = try decoder.decode(OuterCirclesResponse.self, from: data)
        
        return outerResponse.data
    }
    
    func getUserStep(for gameID: String, userID: String) -> AnyPublisher<[UserStep], any Error> {
        let path = APIConfig.userMovementEndpoint
        let fullURL = APIConfig.baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue(gameID, forHTTPHeaderField: "GameID")
        request.setValue(userID, forHTTPHeaderField: "UserID")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
//                print("📦 ユーザーの歩数レスポンスJSON文字列:")
                if let jsonString = String(data: output.data, encoding: .utf8) {
//                    print(jsonString)
                }
                return output.data
            }
            .decode(type: UserStepResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func postUserStep(userID: String, latitude: Double, longitude: Double, steps: Int) -> AnyPublisher<UserStepReportResponse, any Error> {
        let path = APIConfig.sendUserStepEndpoint
        let fullURL = APIConfig.baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        request.setValue(userID, forHTTPHeaderField: "UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        最新の１点だけ bodyで送る
        let body: [String: Any] = [
            "latitude":  latitude,
            "longitude": longitude,
            "steps":     steps
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard let resp = output.response as? HTTPURLResponse,
                      (200..<300).contains(resp.statusCode)
                else { throw URLError(.badServerResponse) }
                return output.data
            }
            .decode(type: UserStepReportResponse.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
//    認証トークン付きでユーザー情報を取得
    func fetchUserProfile() async throws -> UserProfile {
        // 1. トークン取得 or 更新
        let token = try await TokenManager.shared.getAccessToken()
//        nil なら改めてフェッチ
        if token == nil {
            try await TokenManager.shared.fetchAndCacheAccessToken()
        }
        guard let accessToken = token else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // 2. エンドポイント URL
        let path = APIConfig.userProfile
        let fullURL = APIConfig.baseURL.appendingPathComponent(path)
        
        // 3. リクエスト組み立て
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
//        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("userid-79541130-3275-4b90-8677-01323045aca5", forHTTPHeaderField: "UserID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 4. 実行＆ステータスチェック
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            guard 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
        }

        // 5. デコードして返却
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
}
