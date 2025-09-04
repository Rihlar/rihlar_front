//
//  PlayerPosition.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import Foundation
import CoreLocation
import MapKit

/// プレイヤーの位置情報を監視し、地図の表示範囲を更新／移動経路をトラッキングする
class PlayerPosition: NSObject, ObservableObject, CLLocationManagerDelegate {
//     MARK: - 位置情報管理
//     CLLocationManager のインスタンス。権限要求と更新開始に使用
    private let manager = CLLocationManager()
    
//     MARK: - 許可状態管理
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationPermissionGranted: Bool = false
    
//     MARK: - 地図表示関連
//    現在の地図表示領域（中心座標＋ズーム度合）を保持
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
//     起動直後に一度だけ region を現在地で設定したかどうかを判定
    private var didSetInitialRegion: Bool = false
//     追従モード：true のとき、位置更新に応じて region を自動的に書き換える
    @Published var isFollowing: Bool = true
    @Published var recenterTrigger = false
    
//     MARK: - トラッキング関連
//     アプリ起動後からの通過座標を時系列で保持
    @Published private(set) var track: [CLLocationCoordinate2D] = []
//    最新のユーザー位置を公開
    @Published var currentLocation: CLLocationCoordinate2D?
//     前回取得した位置を保持し、移動距離判定に使用
    private var lastLocation: CLLocation?
//     移動判定の閾値（メートル）: この距離未満の更新はスキップ
    private let distanceThreshold: CLLocationDistance = 3.0

//     MARK: - 初期化
    override init() {
        super.init()
//         デリゲート設定
        manager.delegate = self
//         精度設定
        manager.desiredAccuracy = kCLLocationAccuracyBest
//         初期状態を設定
        locationPermissionStatus = manager.authorizationStatus
        updatePermissionStatus()
    }
    
    // 許可状態の更新
    private func updatePermissionStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("🔐 位置情報許可状態更新:")
            print("  - Status: \(self.locationPermissionStatus)")
            print("  - IsGranted: \(self.isLocationPermissionGranted)")
            
            switch self.locationPermissionStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ 位置情報許可: 承認済み")
                self.isLocationPermissionGranted = true
                self.manager.startUpdatingLocation()
            case .denied:
                print("❌ 位置情報許可: 拒否")
                self.isLocationPermissionGranted = false
            case .restricted:
                print("❌ 位置情報許可: 制限")
                self.isLocationPermissionGranted = false
            case .notDetermined:
                print("⏳ 位置情報許可: 未決定 - 許可要求中")
                self.isLocationPermissionGranted = false
                self.manager.requestWhenInUseAuthorization()
            @unknown default:
                print("❓ 位置情報許可: 不明な状態")
                self.isLocationPermissionGranted = false
            }
        }
    }

//     MARK: - CLLocationManagerDelegate
    
    // 位置情報の許可状態が変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔄 位置情報許可状態変更: \(status)")
        DispatchQueue.main.async { [weak self] in
            self?.locationPermissionStatus = status
            self?.updatePermissionStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//         最新の位置情報を取得
        guard let newLocation = locations.last else { return }
        
//        最新位置を currentLocation にセット
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = newLocation.coordinate
        }

//         --- (1) 初回更新時のみ region を現在地に設定 ---
        if !didSetInitialRegion {
            didSetInitialRegion = true
//             地図の表示範囲を現在地に更新
            updateRegion(to: newLocation)
//             最初の位置を lastLocation として保持
            lastLocation = newLocation
//             トラック配列に最初の座標を追加
            track.append(newLocation.coordinate)
            return
        }

//         --- (2) 閾値以下の移動はスキップ ---
        if let prev = lastLocation {
            let movedDistance = newLocation.distance(from: prev)
            if movedDistance < distanceThreshold {
//                 小さい移動なら更新せずに lastLocation を更新して終了
                lastLocation = newLocation
                return
            }
        }

//         --- (3) 有効な移動として処理 ---
        lastLocation = newLocation
//         移動座標をトラックに追加
        track.append(newLocation.coordinate)
        
//         --- (4) 追従モード中なら地図中心を更新 ---
        if isFollowing {
            updateRegion(to: newLocation)
        }
    }

//     MARK: - 地図範囲更新ヘルパー
    private func updateRegion(to location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
//    MARK: API などから取得した過去の座標を初期設定する
    func seedTrack(with coords: [CLLocationCoordinate2D]) {
        // 既存の track をクリアしてから
        self.track = coords
        
        // “最後に取得した位置” を更新しておく
        if let last = coords.last {
            self.lastLocation = CLLocation(latitude: last.latitude,
                                           longitude: last.longitude)
        }
        
        // 初回 region 設定済みフラグを立てておけば、
        // CircleMap の updateUIView 側で初回サイクルから描画される
        self.didSetInitialRegion = true
    }

//     MARK: - 追従モード再開
//   　外部から呼び出し、追従モードを ON に戻す
    func resumeFollow() {
        isFollowing = true
        recenterTrigger = true
    }
}

