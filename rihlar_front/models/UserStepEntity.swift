//
//  UserStepEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/04.
//

import Foundation

/// API から帰ってくる全体のレスポンス
struct UserStepResponse: Codable {
    let data: [UserStep]   // 通過地点の配列
    let result: String      // 成功／失敗などのステータス文字列
}
