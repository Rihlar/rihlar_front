//
//  TeamCirclesEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/30.
//

import Foundation

struct OuterResponse: Codable {
    let data: [String: TeamCirclesEntity]

    // サーバーは "Data" という大文字なので CodingKeys が必要
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

/// JSON の中身だけ受け取る Codable 型
struct TeamCirclesEntity: Codable {
    let teamID: String
    let circles: [GameCircle]?

    enum CodingKeys: String, CodingKey {
        case teamID = "TeamID"
        case circles = "Circles"
    }
}

struct GameCircle: Codable {
    let circleID: String
    let gameID: String
    let size: Int
    let level: Int
    let latitude: Double
    let longitude: Double
    let imageID: String
    let timeStamp: Int

    enum CodingKeys: String, CodingKey {
        case circleID = "CircleID"
        case gameID = "GameID"
        case size = "Size"
        case level = "Level"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case imageID = "ImageID"
        case timeStamp = "TimeStamp"
    }
}

