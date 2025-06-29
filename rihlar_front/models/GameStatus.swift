//
//  GameStatus.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//


//    責務：DB や API の Int → enum への安全なマッピング。
//    メリット：数字だけでなく名前付きケースで扱えるのでコード可読性 UP。
/// ゲームステータス
enum GameStatus: Int, Codable {
    case notStarted = 0   // 開始前
    case inProgress = 1   // 実施中
    case ended      = 2   // 終了後

    /// 表示用の文字列など、付随情報を持たせても OK
    var description: String {
        switch self {
        case .notStarted: return "ゲーム開始前"
        case .inProgress: return "ゲーム実施中"
        case .ended:      return "ゲーム終了"
        }
    }
}
