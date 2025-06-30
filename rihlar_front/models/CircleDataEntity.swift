//
//  CircleDataEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/30.
//

import Foundation
import CoreLocation

/// １つの円データ
struct CircleDataEntity: Codable, Identifiable {
    let circleID: String    // JSON の "CircleID"
    let gameID: String      // JSON の "GameID"
    let size: Int           // JSON の "Size"
    let level: Int          // JSON の "Level"
    let latitude: Double    // JSON の "Latitude"
    let longitude: Double   // JSON の "Longitude"
    let imageID: String?    // JSON の "ImageID" （空文字 or null になることも）
    let timeStamp: TimeInterval  // JSON の "TimeStamp"

    // Identifiable に対応
    var id: String { circleID }
    
    enum CodingKeys: String, CodingKey {
        case circleID  = "CircleID"
        case gameID    = "GameID"
        case size      = "Size"
        case level     = "Level"
        case latitude  = "Latitude"
        case longitude = "Longitude"
        case imageID   = "ImageID"
        case timeStamp = "TimeStamp"
    }
    
    // CoreLocation の型に変換するヘルパー
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

