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
    func fetchGame(id: String) -> AnyPublisher<Game, Error> {
        let url = URL(string: "https://api.example.com/games/\(id)")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Game.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCircles(for gameID: String) -> AnyPublisher<CirclesResponse, Error> {
        let url = URL(string: "https://api.example.com/games/\(gameID)/circles")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CirclesResponse.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
