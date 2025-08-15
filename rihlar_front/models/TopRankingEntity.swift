//
//  TopRankingEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/08/13.
//

import Foundation

// ランキング GET
struct TopRankingEntity: Codable {
    let data: TopRankingData
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

// データ部分の構造体
struct TopRankingData: Codable {
    let ranks: [TeamRanking]
    let selfRanking: SelfTeamRanking
    
    enum CodingKeys: String, CodingKey {
        case ranks
        case selfRanking = "self"
    }
}

// 個別のチームランキング情報
struct TeamRanking: Codable {
    let teamID: String
    let userName: String
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case teamID   = "TeamID"
        case userName = "UserName"
        case points   = "Points"
    }
}

struct SelfTeamRanking: Codable {
    let rank: Int
    let point: Int
    let userName: String
    let teamID: String
    
    enum CodingKeys: String, CodingKey {
        case rank
        case point
        case userName = "UserName"
        case teamID   = "TeamID"
    }
}
