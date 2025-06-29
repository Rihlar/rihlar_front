//
//  MockGameService.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation
import Combine

//    責務：固定データ or ローカル JSON を返す。
//    利用シーン：Unit Test、SwiftUI Preview、本番 API 未完成時の動作確認。
/// テスト用のダミー実装
class MockGameService: GameServiceProtocol {
    func fetchGame(id: String) -> AnyPublisher<Game, Error> {
        let sample = Game(
            gameID: id,
            startTime: Date().addingTimeInterval(-60),
            endTime: Date().addingTimeInterval(300),
            flag: 0, type: 0,
            teams: ["Red","Blue"],
            statusRaw: 1,
            regionID: "tokyo"
        )
        return Just(sample)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

