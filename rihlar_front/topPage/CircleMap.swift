//
//  CircleMapView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import SwiftUI
import MapKit

/// ─────────────────────────────────────────────────────────
/// CircleMapView：
///   ・MKMapView を SwiftUI で使うための UIViewRepresentable ラッパー
///   ・showsUserLocation = true で青い現在地マーカーを表示
///   ・userTrackingMode = .follow で現在地に追従
///   ・MKCircle をオーバーレイとして追加し、円を描画する
/// ─────────────────────────────────────────────────────────
struct CircleMap: UIViewRepresentable {
    /// 位置情報を提供する LocationManager
    @ObservedObject var locationManager: LocationManager

    /// 円の中心を任意で指定（例：JR大阪駅など）
    let circleCenters: [CLLocationCoordinate2D]

    /// 円の半径（メートル）
    let radius: CLLocationDistance = 500

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // 現在地マーカーを表示
        mapView.showsUserLocation = true
        // 追従モード（常に現在地に画面を追いかける）
        mapView.userTrackingMode = .follow

        // ─── 初期表示は「現在地」を中心に少しズームしておく ───
        //  locationManager.region.center は、
        //  ContentView の .onReceive で初回設定されるようにしておく必要があります。
        context.coordinator.isSettingRegionProgrammatically = true
        let initialCenter = locationManager.region.center
        let initialRegion = MKCoordinateRegion(
            center: initialCenter,
            latitudinalMeters: radius * 2.5,
            longitudinalMeters: radius * 2.5
        )
        mapView.setRegion(initialRegion, animated: false)

        // 複数の円をループして追加
        if !circleCenters.isEmpty {
            for center in circleCenters {
                let circle = MKCircle(center: center, radius: radius)
                mapView.addOverlay(circle)
            }
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 位置更新のたびに呼ばれる。isFollowing が true の場合だけ地図を追従
        if locationManager.isFollowing {
            context.coordinator.isSettingRegionProgrammatically = true
            let currentCenter = locationManager.region.center
            let regionToShow = MKCoordinateRegion(
                center: currentCenter,
                latitudinalMeters: radius * 2.5,
                longitudinalMeters: radius * 2.5
            )
            uiView.setRegion(regionToShow, animated: true)
        }
        
        // ─── 円は飾りとして「circleCenter」に固定 ───
        uiView.removeOverlays(uiView.overlays)
        
        // 配列内の各座標に円を追加
        if !circleCenters.isEmpty {
            for center in circleCenters {
                let circle = MKCircle(center: center, radius: radius)
                uiView.addOverlay(circle)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CircleMap
        
        var isSettingRegionProgrammatically: Bool = false
        
        init(_ parent: CircleMap) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.6)
                renderer.lineWidth = 2
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if isSettingRegionProgrammatically {
                isSettingRegionProgrammatically = false
                return
            }
            // ここはユーザーが地図を操作したときだけ来る
            DispatchQueue.main.async {
                    self.parent.locationManager.isFollowing = false
                }
        }
    }
}
