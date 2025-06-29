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
        // 2025-06-29 15:00:00 JST を固定
        let start = DateComponents(
            calendar: .current,
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            year: 2025, month: 6, day: 29,
            hour: 15, minute: 0, second: 0
        ).date!
        
        let end = DateComponents(
            calendar: .current,
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            year: 2025, month: 6, day: 31,
            hour: 15, minute: 0, second: 0
        ).date!
        
        let sample = Game(
            gameID: id,
            startTime: start,
            endTime: end,
            flag: 0,
            type: 0,
            teams: ["Red","Blue"],
            statusRaw: 0,
            regionID: "tokyo"
        )
        return Just(sample)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

