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
    
    func fetchCircles(for gameID: String) -> AnyPublisher<CirclesResponse, Error> {
            // ① サンプル JSON を埋め込む
        let jsonString = """
        {
          "Top1": {
            "TeamID": "teamid-2b511a8a-cbec-4389-a41d-770593cde0a3",
            "Circles": [
              {
                "CircleID": "circle-96380054-f9a7-4ecd-83f8-358f5145a12f",
                "GameID": "adminGame-7ffcbc90-e8fe-4d9c-8c40-f9f94167dd07",
                "Size": 10001,
                "Level": 3,
                "Latitude": 34.687315,
                "Longitude": 135.525813,
                "ImageID": "",
                "TimeStamp": 1751256854
              }
            ]
          },
          "Top2": {
            "TeamID": "teamid-a1b2c3d4-e5f6-7890-1234-567890abcdef",
            "Circles": [
              {
                "CircleID": "circle-a1b2c3d4-e5f6-7890-1234-567890abcdef",
                "GameID": "adminGame-f1e2d3c4-b5a6-9876-5432-10fedcba9876",
                "Size": 10001,
                "Level": 4,
                "Latitude": 34.661793,
                "Longitude": 135.501833,
                "ImageID": "",
                "TimeStamp": 1751260000
              },
              {
                "CircleID": "circle-b2c3d4e5-f6a7-8901-2345-67890abcdef1",
                "GameID": "adminGame-e1d2c3b4-a5f6-7890-1234-567890abcdef",
                "Size": 1001,
                "Level": 3,
                "Latitude": 34.705525,
                "Longitude": 135.500971,
                "ImageID": "",
                "TimeStamp": 1751261000
              }
            ]
          },
          "Top3": {
            "TeamID": "teamid-f6e5d4c3-b2a1-0987-6543-210fedcba987",
            "Circles": [
              {
                "CircleID": "circle-f6e5d4c3-b2a1-0987-6543-210fedcba987",
                "GameID": "adminGame-98765432-10fe-dcba-9876-543210fedcba",
                "Size": 10001,
                "Level": 2,
                "Latitude": 34.647501,
                "Longitude": 135.513381,
                "ImageID": "",
                "TimeStamp": 1751270000
              },
              {
                "CircleID": "circle-d4c3b2a1-0987-6543-210f-edcba9876543",
                "GameID": "adminGame-87654321-0fed-cba9-8765-43210fedcba9",
                "Size": 3001,
                "Level": 4,
                "Latitude": 34.657222,
                "Longitude": 135.437222,
                "ImageID": "",
                "TimeStamp": 1751271000
              },
              {
                "CircleID": "circle-c3b2a109-8765-4321-0fed-cba987654321",
                "GameID": "adminGame-76543210-fedc-ba98-7654-3210fedcba98",
                "Size": 1001,
                "Level": 1,
                "Latitude": 34.723909,
                "Longitude": 135.523116,
                "ImageID": "",
                "TimeStamp": 1751272000
              }
            ]
          },
          "Other": {
            "TeamID": "teamid-1a2b3c4d-5e6f-7890-abcd-ef1234567890",
            "Circles": [
              {
                "CircleID": "circle-1a2b3c4d-5e6f-7890-abcd-ef1234567890",
                "GameID": "adminGame-abcdef12-3456-7890-abcd-ef1234567890",
                "Size": 10001,
                "Level": 5,
                "Latitude": 34.569444,
                "Longitude": 135.482222,
                "ImageID": "",
                "TimeStamp": 1751280000
              },
              {
                "CircleID": "circle-2b3c4d5e-6f7a-8901-bcde-f1234567890a",
                "GameID": "adminGame-bcdef123-4567-8901-cdef-1234567890ab",
                "Size": 3001,
                "Level": 4,
                "Latitude": 34.667112,
                "Longitude": 135.600261,
                "ImageID": "",
                "TimeStamp": 1751281000
              }
            ]
          },
          "Self": {
            "TeamID": "teamid-self-1234-5678-90ab-cdefghijkl",
            "Circles": [
              {
                "CircleID": "circle-self-a1b2-c3d4-e5f6-7890abcdef",
                "GameID": "adminGame-self-f1e2-d3c4-b5a6-9876543210",
                "Size": 10001,
                "Level": 3,
                "Latitude": 34.673041,
                "Longitude": 135.526201,
                "ImageID": "imageid-f7b3a9d1-c8e0-4f2a-8b6d-1e0c9a8b7c6d",
                "TimeStamp": 1751290000
              },
              {
                "CircleID": "circle-self-b2c3-d4e5-f6a7-8901234567",
                "GameID": "adminGame-self-d1c2-b3a4-e5f6-7890123456",
                "Size": 1001,
                "Level": 2,
                "Latitude": 34.605271,
                "Longitude": 135.510416,
                "ImageID": "imageid-e9c1b3d5-a7f8-4e0c-9d2b-1a3f5b7d9e0c",
                "TimeStamp": 1751291000
              }
            ]
          }
        }
        """


        let data = Data(jsonString.utf8)
        
        // ② JSONDecoder で decode
        let decoder = JSONDecoder()
        // （上のキーが最適にマッピングできなければ CodingKeys を使ってください）
        do {
            let resp = try decoder.decode(CirclesResponse.self, from: data)
            return Just(resp)
              .delay(for: .milliseconds(100), scheduler: RunLoop.main)
              .setFailureType(to: Error.self)
              .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

