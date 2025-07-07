//
//  UserStepReportResponse.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/07.
//

import Foundation

/// POST /gcore/report/movement のレスポンス
struct UserStepReportResponse: Decodable {
    let result: String
}
