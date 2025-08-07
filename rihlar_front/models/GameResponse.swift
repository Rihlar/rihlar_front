//
//  GameResponse.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/08.
//

import Foundation

/// API から返ってくる「Data」配列全体を受け取るラッパー
struct GameResponse: Codable {
    let data: Game
    private enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
    
    /// 個別ゲーム情報
    struct Game: Codable {
        let IsAdminJoined:  Bool
        let admin: adminGame
        let system: systemGame
    }
    
    struct adminGame: Codable {
        let IsFinished:  Bool
        let IsStarted:   Bool
        let GameID: String
        let StartTime: Date
        let EndTime: Date
    }

    struct systemGame: Codable {
        let GameID: String
    }
}

