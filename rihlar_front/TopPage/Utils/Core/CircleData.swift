//
//  CircleData.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import Foundation
import CoreLocation

struct CircleData: Codable, Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let size: Int

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
