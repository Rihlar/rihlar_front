//
//  Bearing.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/19.
//

import CoreLocation

extension CLLocationCoordinate2D {
  /// self → to の方位角を度で返す（北を 0度とした時計回り）
  func bearing(to: CLLocationCoordinate2D) -> Double {
    let φ1 = self.latitude.degreesToRadians
    let φ2 = to.latitude.degreesToRadians
    let Δλ = (to.longitude - self.longitude).degreesToRadians
    let y = sin(Δλ) * cos(φ2)
    let x = cos(φ1)*sin(φ2) - sin(φ1)*cos(φ2)*cos(Δλ)
    let θ = atan2(y, x)
    return (θ.radiansToDegrees + 360).truncatingRemainder(dividingBy: 360)
  }
}

private extension Double {
  var degreesToRadians: Double { self * .pi / 180 }
  var radiansToDegrees: Double { self * 180 / .pi }
}
