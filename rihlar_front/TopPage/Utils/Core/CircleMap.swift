//
//  CircleMapView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/09.
//

import SwiftUI
import MapKit

/// UIViewRepresentable で MKMapView を利用し、
/// JSON から取得したデータに基づく円オーバーレイを
/// アニメーション付きで表示するコンポーネント
struct CircleMap: UIViewRepresentable {
    @ObservedObject var playerPosition: PlayerPosition
    let circles: [CircleData]

    /// UIKit の MKMapView を生成し、初期設定を行う
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true                  // 現在地マーカー
        mapView.userTrackingMode = .follow                // 現在地追従

        // 初期表示領域：LocationManager.region の中心を設定
        context.coordinator.isSettingRegionProgrammatically = true
        let center = playerPosition.region.center
        let initialRegion = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(initialRegion, animated: false)

        return mapView
    }

    /// SwiftUI から呼ばれる更新メソッド
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 追従モード中は再センタリング
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

        // 初回ロード完了フラグ && アニメーション中でなければオーバーレイを更新
        if context.coordinator.isFirstLoadFlag && !context.coordinator.isAnimatingCircles {
            // 既存のオーバーレイを削除
            uiView.removeOverlays(uiView.overlays)
            // JSON データに基づく円を追加
            addCircles(to: uiView, context: context)
        }
    }

    /// coordinator を生成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - 円追加ロジック（旧コードを変更せずコメント追加）
    private func addCircles(to mapView: MKMapView, context: Context) {
        let coordinator = context.coordinator

        // アニメーション中は再実行を抑制
        coordinator.isAnimatingCircles = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            coordinator.isAnimatingCircles = false
        }

        // 初回のみアニメーション付きオーバーレイ追加
        if !coordinator.hasAnimatedCircles && !circles.isEmpty {
            for circleData in circles {
                let radius = computedRadius(for: circleData.size)
                print("▶️ [CircleMap] 初回アニメーション: \(circleData.coordinate), radius: \(radius)")

                // 円オーバーレイを追加
                let overlay = MKCircle(center: circleData.coordinate, radius: radius)
                mapView.addOverlay(overlay)

                // レンダラー取得後にフェードインさせる
                DispatchQueue.main.async {
                    if let renderer = mapView.renderer(for: overlay) as? MKCircleRenderer {
                        renderer.alpha = 0
                        UIView.animate(withDuration: 2.0) {
                            renderer.alpha = 1.0
                        }
                    }
                }
            }
            coordinator.hasAnimatedCircles = true

        } else {
            // 2回目以降は静的オーバーレイのみ
            for circleData in circles {
                let radius = computedRadius(for: circleData.size)
                print("▶️ [CircleMap] 静的オーバーレイ: \(circleData.coordinate), radius: \(radius)")
                let overlay = MKCircle(center: circleData.coordinate, radius: radius)
                mapView.addOverlay(overlay)
            }
        }
    }

    /// size（歩数等）からメートル半径を返す
    private func computedRadius(for size: Int) -> CLLocationDistance {
        switch size {
        case 0..<1000:      return 50
        case 1000..<3000:   return 100
        case 3000..<6000:   return 200
        case 6000..<10000:  return 300
        default:            return 400
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: CircleMap
        var isSettingRegionProgrammatically = false   // プログラム移動制御
        var hasAnimatedCircles = false              // 初回アニメーション済みフラグ
        var isFirstLoadFlag = false                  // 初回ロード完了フラグ
        var isAnimatingCircles = false               // アニメーション中フラグ

        init(_ parent: CircleMap) {
            self.parent = parent
        }

        // 地図タイル読み込み完了でフラグを立てる
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("▶️ [Coordinator] didFinishLoadingMap – 初回ロードフラグ ON")
            isFirstLoadFlag = true
        }

        // MKOverlay の描画設定
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.6)
                renderer.fillColor   = UIColor.blue.withAlphaComponent(0.2)
                renderer.lineWidth   = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // ユーザー操作かプログラム移動かを判定
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if isSettingRegionProgrammatically {
                isSettingRegionProgrammatically = false
                return
            }
            DispatchQueue.main.async {
                self.parent.playerPosition.isFollowing = false
            }
        }
    }
}

