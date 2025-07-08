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
    let circlesByTeam: [TeamCircles]
    let userStepByTeam: [UserStep]
    let currentUserTeamID: String = "teamid-32f5eb5f-534b-439e-990e-349e52d70970"
    let gameStatus: GameStatus
    let gameType: GameType

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        context.coordinator.isSettingRegionProgrammatically = true
        let center = playerPosition.region.center
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.resetIfNeeded()
        uiView.removeOverlays(uiView.overlays)

        if playerPosition.isFollowing {
            context.coordinator.isSettingRegionProgrammatically = true
            let center = playerPosition.region.center
            uiView.setRegion(
                MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                ), animated: true
            )
        }

        // Always show track polyline
        let coords = playerPosition.track
        if coords.count >= 2 {
            uiView.addOverlay(MKPolyline(coordinates: coords, count: coords.count))
        }

        // Show circles if in progress or in collection mode
        if gameStatus == .inProgress || gameType == .system {
            addOverlays(to: uiView, using: context.coordinator)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func addOverlays(
        to mapView: MKMapView,
        using coordinator: Coordinator
    ) {
        // ① ３日以内フィルタのための cutoff を計算
        let threeDays: TimeInterval = 3 * 24 * 60 * 60
        let cutoff = Date().addingTimeInterval(-threeDays)

        // ② gameType によって表示対象データを取得
        var items: [(String, CLLocationCoordinate2D, CLLocationDistance)] = []

        if gameType == .system {
            // ── コレクションモード ──
            // 自分のチームだけ、歩数ではなく circlesByTeam の自分チームの円を表示
            if let myTeam = circlesByTeam.first(where: { $0.groupName == "Self" }) {
                for circle in myTeam.circles
                    .filter({ Date(timeIntervalSince1970: $0.timeStamp) >= cutoff })
                {
                    items.append((
                        "Self",
                        circle.coordinate,
                        CLLocationDistance(circle.size)
                    ))
                }
            }
        } else {
            // ── 対戦モード ──
            // 全チームの円を表示
            for team in circlesByTeam {
                for circle in team.circles
                where Date(timeIntervalSince1970: circle.timeStamp) >= cutoff {
                    items.append((
                        group: team.groupName,
                        coord: circle.coordinate,
                        radius: CLLocationDistance(circle.size)
                    ))
                }
            }
        }
        
        print("🌀 [CircleMap] mode=\(gameType) items.count=\(items.count)")
        for (i, item) in items.enumerated() {
            print("  \(i): group=\(item.0), coord=\(item.1), radius=\(item.2)")
        }

        // ④ アニメーション抑制フラグ
        coordinator.isAnimatingCircles = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            coordinator.isAnimatingCircles = false
        }

        // ⑤ 初回 → フェードイン、以降 → 静的描画
        if !coordinator.hasAnimatedCircles {
            for (group, coord, radius) in items {
                let circle = MKCircle(center: coord, radius: radius)
                circle.title = group
                mapView.addOverlay(circle)
                DispatchQueue.main.async {
                    if let r = mapView.renderer(for: circle) as? MKCircleRenderer {
                        r.alpha = 0
                        UIView.animate(withDuration: 2.0) { r.alpha = 1.0 }
                    }
                }
            }
            coordinator.hasAnimatedCircles = true

        } else {
            for (group, coord, radius) in items {
                let circle = MKCircle(center: coord, radius: radius)
                circle.title = group
                mapView.addOverlay(circle)
            }
        }
    }


    private func color(for group: String) -> UIColor {
        switch group {
        case "Top1": return .orange
        case "Top2": return .red
        case "Top3": return .green
        case "Other": return .white
        case "Self": return .blue
        default: return .black
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: CircleMap
        var isSettingRegionProgrammatically = false
        var hasAnimatedCircles = false
        var isAnimatingCircles = false
        private var lastGameType: GameType
        private var lastGameStatus: GameStatus

        init(_ parent: CircleMap) {
            self.parent = parent
            self.lastGameType = parent.gameType
            self.lastGameStatus = parent.gameStatus
        }

        func resetIfNeeded() {
            if lastGameType != parent.gameType
                || lastGameStatus != parent.gameStatus {
                hasAnimatedCircles = false
                lastGameType = parent.gameType
                lastGameStatus = parent.gameStatus
            }
        }

        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            // Not strictly needed now that updateUIView always refreshes
        }

        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let r = MKCircleRenderer(circle: circle)
                let group = circle.title ?? "unknown"
                let color = parent.color(for: group)
                r.strokeColor = color.withAlphaComponent(0.6)
                r.fillColor = color.withAlphaComponent(0.3)
                r.lineWidth = 2
                return r
            } else if let line = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: line)
                r.strokeColor = .systemBlue
                r.lineWidth = 4
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(
            _ mapView: MKMapView,
            regionWillChangeAnimated animated: Bool
        ) {
            if isSettingRegionProgrammatically {
                isSettingRegionProgrammatically = false
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.parent.playerPosition.isFollowing = false
                }
            }
        }
    }
}
