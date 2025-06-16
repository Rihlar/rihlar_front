//
//  LocationManager.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    // 地図の表示領域 (中心＋ズーム) を保持
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    
    /// 起動直後に一度だけ region を現在地で更新したかどうか
    private var didSetInitialRegion:Bool = false
    
    /// これが true のときだけ、位置情報更新で region を書き換える
    @Published var isFollowing: Bool = true
    
    private var lastLocation: CLLocation?
    private let distanceThreshold: CLLocationDistance = 5.0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // ── ①「初回」だけ現在地で region を更新する ──
        if !didSetInitialRegion {
            // 「初回更新前」であるため、現在地の region に書き換えておく
            didSetInitialRegion = true
            updateRegion(to: newLocation)
            // 初回は距離判定も追従判定もスキップし、そのまま return
            lastLocation = newLocation
            return
        }
        
        // 位置が変わっていなかったら無視
        if let prev = lastLocation {
            let movedDistance = newLocation.distance(from: prev)
            // 閾値未満の移動なら、書き換えせず return
            if movedDistance < distanceThreshold {
                lastLocation = newLocation
                return
            }
        }
        // (2) ここまでくる = 「距離閾値を超えて移動」 or 「初回以外の更新」
        lastLocation = newLocation
        
        // (3) 追従モードが ON のときだけ region を更新
        // isFollowing が true のときだけ、region を更新する
        if isFollowing {
            updateRegion(to: newLocation)
        }
    }

    private func updateRegion(to location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    /// 外部から「追従モードに戻したい」ときに呼ぶ
    func resumeFollow() {
        isFollowing = true
    }
}

