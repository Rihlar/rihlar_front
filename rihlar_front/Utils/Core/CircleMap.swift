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
    let circlesByTeam: [TeamCircles]

///     UIKit の MKMapView を生成し、初期設定を行う
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true                  // 現在地マーカー
        mapView.userTrackingMode = .follow                // 現在地追従

//         初期表示領域：LocationManager.region の中心を設定
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

///    SwiftUI から呼ばれる更新メソッド
    func updateUIView(_ uiView: MKMapView, context: Context) {
//         追従モード中は再センタリング
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

//         初回ロード完了フラグ && アニメーション中でなければオーバーレイを更新
        if context.coordinator.isFirstLoadFlag && !context.coordinator.isAnimatingCircles {
            // 既存のオーバーレイを削除
            uiView.removeOverlays(uiView.overlays)
            
//             通過地点をつなぐ線を追加
            let coords = playerPosition.track
            if coords.count >= 2 {
                let polyline = MKPolyline(coordinates: coords, count: coords.count)
                uiView.addOverlay(polyline)
            }
//             JSON データに基づく円を追加
            addOverlays(to: uiView, using: context.coordinator)
        }
    }

///    coordinator を生成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

//     MARK: - 円追加ロジック
    private func addOverlays(to mapView: MKMapView, using coordinator: Coordinator) {
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
//        通過地点をつなぐ線を追加
        let coords = playerPosition.track
        if coords.count >= 2 {
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            mapView.addOverlay(polyline)
        }
        
        // ─────────── ソート準備 ───────────
         let allCircles: [(group: String, data: CircleDataEntity)] =
             circlesByTeam.flatMap { team in
                 team.circles.map { (team.groupName, $0) }
             }
         let sortedCircles = allCircles.sorted { a, b in
             if a.data.level != b.data.level {
                 return a.data.level > b.data.level
             } else {
                 return a.data.timeStamp > b.data.timeStamp
             }
         }

//         アニメーション中は再実行を抑制
        coordinator.isAnimatingCircles = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            coordinator.isAnimatingCircles = false
        }

//         初回のみアニメーション付きオーバーレイ追加
        if !coordinator.hasAnimatedCircles && !circlesByTeam.isEmpty {
        // ─────────── 初回アニメーション ───────────
        for team in circlesByTeam {
            let color = color(for: team.groupName)
            for circleData in team.circles {
//                circleData.timeStamp は秒刻みの UNIX 時間
                let circleDate = Date(timeIntervalSince1970: circleData.timeStamp)
//                ３日前より古いならスキップ
                guard circleDate >= threeDaysAgo else { continue }
                let overlay = MKCircle(center: circleData.coordinate, radius: CLLocationDistance(circleData.size))
                overlay.title = team.groupName
                
//                print("▶️ addOverlays: team=\(team.groupName), color=\(color)")
                
                mapView.addOverlay(overlay)
                
                // レンダラー取得後にフェードイン
                DispatchQueue.main.async {
                    if let renderer = mapView.renderer(for: overlay) as? MKCircleRenderer {
                        renderer.alpha = 0
                        UIView.animate(withDuration: 2.0) {
                            renderer.alpha = 1.0
                        }
                    }
                }
            }
        }
        coordinator.hasAnimatedCircles = true

        } else {
//             2回目以降は静的オーバーレイのみ
        for team in circlesByTeam {
            let color = color(for: team.groupName)
            for circleData in team.circles {
//                circleData.timeStamp は秒刻みの UNIX 時間
                let circleDate = Date(timeIntervalSince1970: circleData.timeStamp)
//                ３日前より古いならスキップ
                guard circleDate >= threeDaysAgo else { continue }
                    let overlay = MKCircle(center: circleData.coordinate, radius: CLLocationDistance(circleData.size))
                    overlay.title = team.groupName
                    
//                    print("▶️ addOverlays(static): team=\(team.groupName), color=\(color)")
                    
                    mapView.addOverlay(overlay)
                }
            }
        }
    }

    private func color(for group: String) -> UIColor {
        switch group {
        case "Top1":  return .red
        case "Top2":  return .green
        case "Top3":  return .blue
        case "Other": return .gray
        case "Self":  return .purple
        default:      return .black
        }
    }

//     MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: CircleMap
        var isSettingRegionProgrammatically = false   // プログラム移動制御
        var hasAnimatedCircles = false              // 初回アニメーション済みフラグ
        var isFirstLoadFlag = false                  // 初回ロード完了フラグ
        var isAnimatingCircles = false               // アニメーション中フラグ

        init(_ parent: CircleMap) {
            self.parent = parent
        }

//         地図タイル読み込み完了でフラグを立てる
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//            print("▶️ [Coordinator] didFinishLoadingMap – 初回ロードフラグ ON")
            isFirstLoadFlag = true
            parent.addOverlays(to: mapView, using: self)
        }

///         MKOverlay の描画設定
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                
//                 overlay.title に入っている groupName を取得
                let group = circle.title ?? "unknown"
//                 groupName に応じた色を取得
                let uiColor = parent.color(for: group)
                
//                 動的に色を設定
                renderer.strokeColor = uiColor.withAlphaComponent(0.6)
                renderer.fillColor   = uiColor.withAlphaComponent(0.3)
//                テストで不透明にしている
//                renderer.strokeColor = uiColor.withAlphaComponent(1.0)
//                renderer.fillColor   = uiColor.withAlphaComponent(1.0)
                renderer.lineWidth   = 2
                
                // デバッグ用プリント（任意）
//                print("▶️ rendererFor: group=\(group), stroke=\(renderer.strokeColor!), fill=\(renderer.fillColor!)")
                
                return renderer
                
            } else if let line = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: line)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth   = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }


///         ユーザー操作かプログラム移動かを判定
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

