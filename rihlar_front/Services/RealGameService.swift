//
//  RealGameService.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation
import Combine

//サンプルのためのもの
private struct GamesResponse: Codable {
    let data: [Game]
    private enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}
//    責務：実際のバックエンドから JSON をフェッチ。
//    注意点：URL やリクエストヘッダ、エラー処理は適宜拡張。
/// 本番 API 叩く実装
class RealGameService: GameServiceProtocol {
//    func fetchGame(id: String) -> AnyPublisher<Game, Error> {
//        let url = URL(string: "https://api.example.com/games/\(id)")!
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: Game.self, decoder: JSONDecoder())
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//    }
    
    func fetchGame(id: String) -> AnyPublisher<[Game], Error> {
        // モック用 JSON
        let json = """
        {
          "Data": [
            {
              "gameID": "gameid-413a287b-213c-414f-a287-c1397db8f9bf",
              "startTime": "2025-07-05T11:46:34.512Z",
              "endTime":   "2025-07-25T11:46:34.512Z",
              "flag":      0,
              "type":      1,
              "teams":     null,
              "status":    0,
              "regionID":  "regionId-c161edb9-6aff-4244-8749-707bff2fa3be"
            },
            {
              "gameID": "gameid-9fcb784b-04a8-49c3-9ed9-ca9588eb86a8",
              "startTime": "2025-07-05T11:46:34.504Z",
              "endTime":   "2025-07-25T11:46:34.504Z",
              "flag":      0,
              "type":      0,
              "teams":     null,
              "status":    1,
              "regionID":  "regionId-c161edb9-6aff-4244-8749-707bff2fa3be"
            }
          ]
        }
        """
        let data = Data(json.utf8)

        let isoFormatter: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [
                .withInternetDateTime,    // "YYYY-MM-DDTHH:mm:ss"
                .withFractionalSeconds    // ".sss"
            ]
            return f
        }()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }

        return Just(data)
            .print("raw JSON")
            .decode(type: GamesResponse.self, decoder: decoder)
            .map { $0.data }           // ここで [Game] を返す
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getTop3CircleRankingURL(for gameID: String, userID: String) -> AnyPublisher<[String: TeamCirclesEntity], Error> {
//        1. path の組み立て
        let path = APIConfig.top3CirclesRankingEndpoint.replacingOccurrences(of: "{gameId}", with: gameID)
        let fullURL = APIConfig.baseURL.appendingPathComponent(path)
        
//        2. URLRequest の生成
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        
//        3. 標準ヘッダー設定
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
//        4. ヘッダー情報にuserIDを追加
        request.setValue(userID, forHTTPHeaderField: "UserID")
        
//        5. dataTaskPublisher 実行
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
//                print("📦 トップ3円のレスポンスJSON文字列:")
                if let jsonString = String(data: output.data, encoding: .utf8) {
//                    print(jsonString)
                }
                return output.data
            }
            .decode(type: OuterCirclesResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
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
}
