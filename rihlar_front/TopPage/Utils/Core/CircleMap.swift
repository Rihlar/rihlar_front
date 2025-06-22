//
//  CircleMapView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import SwiftUI
import MapKit

struct CircleMap: UIViewRepresentable {
    @ObservedObject var playerPosition: PlayerPosition
    let circles: [CircleData]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // 現在地マーカー＆追従
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // 初期表示領域だけセット
        context.coordinator.isSettingRegionProgrammatically = true
        let center = playerPosition.region.center
        mapView.setRegion(
            MKCoordinateRegion(
                center: center,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ),
            animated: false
        )

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 追従モード
        if playerPosition.isFollowing {
            context.coordinator.isSettingRegionProgrammatically = true
            let center = playerPosition.region.center
            uiView.setRegion(
                MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                ),
                animated: true
            )
        }

        if context.coordinator.isFirstLoadFlag
           && !context.coordinator.isAnimatingCircles {
            uiView.removeOverlays(uiView.overlays)
            addCircles(to: uiView, context: context)
        }
    }

    // まったく以前のままのメソッド
    private func addCircles(to mapView: MKMapView, context: Context) {
        let coordinator = context.coordinator
        
        // アニメーション中フラグを立てる
        coordinator.isAnimatingCircles = true
        // アニメーション所要時間後に解除
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            coordinator.isAnimatingCircles = false
        }
        
        if !context.coordinator.hasAnimatedCircles && !circles.isEmpty {
            for circleData in circles {
                let radius = computedRadius(for: circleData.size)
                let fastRadius = 1.0
                print("▶️ [CircleMap] 初回アニメーション: \(circleData.coordinate), radius: \(radius)")
                let overlay = MKCircle(center: circleData.coordinate, radius: radius)
                mapView.addOverlay(overlay)
                
                // ② レンダラーが作られたあとに alpha アニメーション
                DispatchQueue.main.async {
                    if let renderer = mapView.renderer(for: overlay) as? MKCircleRenderer {
                        renderer.alpha = 0
                        UIView.animate(withDuration: 2.0) {
                            renderer.alpha = 1.0
                        }
                    }
                }
            }
            context.coordinator.hasAnimatedCircles = true
        } else {
            for circleData in circles {
                let radius = computedRadius(for: circleData.size)
                print("▶️ [CircleMap] 静的オーバーレイ: \(circleData.coordinate), radius: \(radius)")
                let overlay = MKCircle(center: circleData.coordinate, radius: radius)
                mapView.addOverlay(overlay)
            }
        }
    }

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
        let parent: CircleMap
        var isSettingRegionProgrammatically = false
        var hasAnimatedCircles = false
        var isFirstLoadFlag = false
        var isAnimatingCircles = false

        init(_ parent: CircleMap) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let c = overlay as? MKCircle {
                let r = MKCircleRenderer(circle: c)
                r.strokeColor = UIColor.blue.withAlphaComponent(0.6)
                r.fillColor   = UIColor.blue.withAlphaComponent(0.2)
                r.lineWidth   = 2
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if isSettingRegionProgrammatically {
                isSettingRegionProgrammatically = false
                return
            }
            DispatchQueue.main.async {
                self.parent.playerPosition.isFollowing = false
            }
        }

        // ❶ 地図タイルの読み込み完了後 → フラグをリセット
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("▶️ [Coordinator] didFinishLoadingMap – resetting flagmapViewDidFinishLoadingMap")
            isFirstLoadFlag = true
        }
    }
}

