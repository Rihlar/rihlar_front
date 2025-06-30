//
//  TeamCirclesEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/30.
//

import Foundation

/// JSON の中身だけ受け取る Codable 型
struct TeamCirclesEntity: Codable {
    let teamID: String
    let circles: [CircleDataEntity]

    enum CodingKeys: String, CodingKey {
        case teamID = "TeamID"
        case circles = "Circles"
    }
}

typealias CirclesResponse = [String: TeamCirclesEntity]
