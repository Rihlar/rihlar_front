//
//  Game.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation

/// ゲーム種別
enum GameType: Int, Codable {
    case system = 0  // システムゲーム
    case admin  = 1  // 管理者ゲーム
}

/// 個別ゲーム情報
struct Game: Codable {
    let isJoined:  Bool
    let gameID:    String
    let startTime: Date
    let endTime:   Date
    let flag:      Int
    var type:      GameType    // ← Int から GameType へ

    /// JSON の "teams" は null｜[String] なのでオプショナルに
    let teams:     [String]?

    /// JSON の "status" キーを生の Int として受け取る
    var statusRaw: Int

    let regionID:  String

    /// ステータス enum 変換
    var status: GameStatus {
        GameStatus(rawValue: statusRaw) ?? .notStarted
    }

    /// システムゲームか
    var isSystemGame: Bool { type == .system }
    /// 管理者ゲームか
    var isAdminGame:  Bool { type == .admin }

    private enum CodingKeys: String, CodingKey {
        case isJoined   = "isJoined"
        case gameID     = "gameID"
        case startTime  = "startTime"
        case endTime    = "endTime"
        case flag       = "flag"
        case type       = "type"
        case teams      = "teams"
        case statusRaw  = "status"
        case regionID   = "regionID"
    }
}
