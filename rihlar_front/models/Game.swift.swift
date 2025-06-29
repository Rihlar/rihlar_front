//
//  Game.swift.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation

//    責務：API/DB から来る JSON 形式をそのまま受け取りつつ、 status プロパティで enum 化。
//    補足：CodingKeys を使えば、JSON キーとプロパティ名が異なる場合もマッピング可能。
struct Game: Codable {
    let gameID: String
    let startTime: Date
    let endTime: Date
    let flag: Int
    var type: Int
    let teams: [String]
    var statusRaw: Int
    let regionID: String

    /// 生の Int → enum への変換
    var status: GameStatus {
        GameStatus(rawValue: statusRaw) ?? .notStarted
    }
}
