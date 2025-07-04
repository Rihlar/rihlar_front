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
//    func fetchGame(id: String) -> AnyPublisher<Game, Error> {
//        let url = URL(string: "https://api.example.com/games/\(id)")!
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: Game.self, decoder: JSONDecoder())
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//    }
    
    func fetchGame(id: String) -> AnyPublisher<Game, Error> {
        // 2025-07-4 15:00:00 JST を固定
        let start = DateComponents(
            calendar: .current,
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            year: 2025, month: 7, day: 3,
            hour: 15, minute: 0, second: 0
        ).date!
        
        let end = DateComponents(
            calendar: .current,
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            year: 2025, month: 7, day: 4,
            hour: 15, minute: 0, second: 0
        ).date!
        
        let sample = Game(
            gameID: id,
            startTime: start,
            endTime: end,
            flag: 0,
            type: 1,
            teams: ["Red","Blue"],
            statusRaw: 0,
            regionID: "tokyo"
        )
        return Just(sample)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getTop3CircleRankingURL(for gameID: String) -> AnyPublisher<[String: TeamCirclesEntity], Error> {
        let GameID = "gameid-413a287b-213c-414f-a287-c1397db8f9bf"
        let path = APIConfig.top3CirclesRankingEndpoint.replacingOccurrences(of: "{gameId}", with: GameID)
        let fullURL = APIConfig.baseURL.appendingPathComponent(path)
        return URLSession.shared.dataTaskPublisher(for: fullURL)
            .tryMap { output in
                print("📦 レスポンスJSON文字列:")
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print(jsonString)
                }
                return output.data
            }
            .decode(type: OuterResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
