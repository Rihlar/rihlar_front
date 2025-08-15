//
//  AllGameEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/08/13.
//

import Foundation

// すべてのゲーム一覧
struct AllGameEntity: Codable {
    let Data: [AllGameContents]
}

struct AllGameContents: Codable {
    let isJoined: Bool
    let gameID: String
    let startTime: Date
    let endTime: Date
    let flag: Int
    var type: Int
    var status: Int
    let regionID: String
}
