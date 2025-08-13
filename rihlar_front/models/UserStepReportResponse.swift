//
//  UserStepReportResponse.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/07.
//

import Foundation

/// POST /gcore/report/movement のレスポンス
struct UserStepReportResponse: Decodable {
    let isSystemSuccess: Bool
    let adminGames: [AdminGame]

    // API側のキーとSwiftのプロパティ名をマッピング
    enum CodingKeys: String, CodingKey {
        case isSystemSuccess = "IsSyetemSuccess" // ※ スペルミスっぽいがAPI仕様に合わせる
        case adminGames = "AdminGames"
    }
}

struct AdminGame: Decodable {
    let isSuccess: Bool
    let gameId: String
    let message: String
    let status: Int

    enum CodingKeys: String, CodingKey {
        case isSuccess = "IsSuccess"
        case gameId = "GameId"
        case message = "Message"
        case status = "Status"
    }
}

