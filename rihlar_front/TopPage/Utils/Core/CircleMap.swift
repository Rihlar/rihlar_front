//
//  CircleMapView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import SwiftUI
import MapKit

struct CircleMap: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    /// JSON からデコードしたデータをそのまま渡す
    let circles: [CircleData]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // 現在地マーカー＆追従
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // 初期表示は LocationManager.region の中心
        context.coordinator.isSettingRegionProgrammatically = true
        let center = locationManager.region.center
        let initialRegion = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 500,    // 適当な初期ズーム
            longitudinalMeters: 500
        )
        mapView.setRegion(initialRegion, animated: false)

        // JSONデータに基づく円を追加
        addCircles(to: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 自動追従モード中だけ現在地へ移動
        if locationManager.isFollowing {
            context.coordinator.isSettingRegionProgrammatically = true
            let center = locationManager.region.center
            let region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            uiView.setRegion(region, animated: true)
        }

        // 毎回オーバーレイを更新
        uiView.removeOverlays(uiView.overlays)
        addCircles(to: uiView)
    }

    private func addCircles(to mapView: MKMapView) {
        for circleData in circles {
            let radius = computedRadius(for: circleData.size)
            let overlay = MKCircle(center: circleData.coordinate, radius: radius)
            mapView.addOverlay(overlay)
        }
    }

    /// JSON の "size"（歩数など）から、円の半径をメートルで返すロジック
    private func computedRadius(for size: Int) -> CLLocationDistance {
        switch size {
        case 0..<1000:      return 50
        case 1000..<3000:   return 100
        case 3000..<6000:   return 200
        case 6000..<10000:  return 300
        default:            return 400
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CircleMap
        var isSettingRegionProgrammatically = false

        init(_ parent: CircleMap) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(circle: circle)
                r.strokeColor = UIColor.blue.withAlphaComponent(0.6)
                r.fillColor   = UIColor.blue.withAlphaComponent(0.2)
                r.lineWidth   = 2
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // プログラム的な移動中なら無視
            if isSettingRegionProgrammatically {
                isSettingRegionProgrammatically = false
                return
            }
            // ユーザー操作 → 自由モード
            DispatchQueue.main.async {
                self.parent.locationManager.isFollowing = false
            }
        }
    }
}
