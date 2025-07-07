//
//  GameViewModel.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Combine
import Foundation

//    責務：View 側に必要なデータを保持し、サービスからの取得・エラーも管理。
//    ポイント：Combine を使って非同期を扱い、UI へのバインディングは @Published。
final class GameViewModel: ObservableObject {
    @Published var game: Game?
    @Published var circlesByTeam: [TeamCircles] = []
    @Published var userStepByTeam: [UserStep] = []
    @Published var isLoadingGame = false
    @Published var isLoadingCircles = false
    @Published var isLoadingUserStep = false
    @Published var errorMessage: String?
    
    private let service: GameServiceProtocol
    private let stepsHK: StepsHealthKit
    private var cancellables = Set<AnyCancellable>()
    private var lastSentCoordinate: CLLocationCoordinate2D?

    /// デフォルトで Real、テスト時に Mock を渡せる
    init(service: GameServiceProtocol = RealGameService(), stepsHK: StepsHealthKit = StepsHealthKit()) {
        self.service = service
        self.stepsHK = stepsHK
        fetchGame(by: "テスト用GameID")
    }
    
/// ゲーム情報だけ取得
    func fetchGame(by id: String) {
        isLoadingGame = true
        service.fetchGame(id: id)
            .sink { [weak self] completion in
                self?.isLoadingGame = false
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] game in
                self?.game = game
                print("[DEBUG] fetched game:", game)
            }
            .store(in: &cancellables)
    }
    
/// 円情報だけ取得
    func fetchCircles(for gameID: String, userID: String) {
        isLoadingCircles = true
        service.getTop3CircleRankingURL(for: gameID, userID: userID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    self?.isLoadingCircles = false
                    if case .failure(let err) = completion {
                        print("❌ fetchCircles エラー: \(err.localizedDescription)")
                        self?.errorMessage = err.localizedDescription
                    } else {
                        print("✅ fetchCircles 成功")
                    }
                },
                receiveValue: { [weak self] (respDict: [String: TeamCirclesEntity]) in
//                    print("🌐 fetchCircles レスポンス内容: \(respDict)")
                    // 辞書 → [TeamCircles] へ変換
                    self?.circlesByTeam = respDict.map { key, entity in
                        TeamCircles(
                            groupName: key,
                            teamID: entity.teamID,
                            circles: (entity.circles ?? []).map { circle in
                                CircleDataEntity(
                                    circleID: circle.circleID,
                                    gameID: circle.gameID,
                                    size: circle.size,
                                    level: circle.level,
                                    latitude: circle.latitude,
                                    longitude: circle.longitude,
                                    imageID: circle.imageID,
                                    timeStamp: Double(circle.timeStamp)
                                )
                            }
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
/// ユーザーの歩数情報だけ取得
    func fetchUserStep(for gameID: String, userID: String) {
        isLoadingUserStep = true

        service.getUserStep(for: gameID, userID: userID)
            // UI 更新はメインスレッドで
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoadingUserStep = false
                    if case .failure(let err) = completion {
                        print("❌ fetchUserStep エラー: \(err.localizedDescription)")
                        self.errorMessage = err.localizedDescription
                    } else {
                        print("✅ fetchUserStep 成功")
                    }
                },
                receiveValue: { [weak self] entities in
                    guard let self = self else { return }
                    print("🌐 fetchUserStep レスポンス内容: \(entities)")

                    // UserStepEntity → UserStep に変換
                    self.userStepByTeam = entities.map { e in
                        UserStep(
                            latitude:  e.latitude,
                            longitude: e.longitude,
                            steps:     e.steps,
                            timeStamp: e.timeStamp
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
///    playerPosition.track の変化を監視して最新座標だけを POST
    ///    座標が変わったらPOST
//    func bindPlayerPositionUpdates(for userID: String, playerPosition: PlayerPosition) {
//        playerPosition.$track
//            .dropFirst()                            // 初回シード除外
//            .compactMap { $0.last }                 // 配列の最後の１点だけ
//            .removeDuplicates { a, b in
//                a.latitude == b.latitude && a.longitude == b.longitude
//            }
//            .throttle(for: .seconds(10), scheduler: RunLoop.main, latest: true)
//            .sink { [weak self] latest in
//                guard let self = self else { return }
//                let steps = self.stepsHK.steps // ここは HealthKit 等から実際の歩数を取得してください
//                print("緯度:\(latest.latitude),経度:\(latest.longitude),歩数:\(steps)")
//
//                self.service.postUserStep(
//                    userID:   userID,
//                    latitude: latest.latitude,
//                    longitude: latest.longitude,
//                    steps:    steps
//                )
//                .sink(
//                    receiveCompletion: { comp in
//                        if case .failure(let err) = comp {
//                            print("POST歩数エラー:", err)
//                        }
//                    },
//                    receiveValue: { resp in
//                        print("POST歩数成功:", resp.result)
//                        print("緯度:\(latest.latitude),経度:\(latest.longitude),歩数:\(steps)")
//                    }
//                )
//                .store(in: &self.cancellables)
//            }
//            .store(in: &cancellables)
//    }
    
//    10秒タイマー
    func bindPlayerPositionUpdates(for userID: String, playerPosition: PlayerPosition) {
        Timer
          .publish(every: 10.0, on: .main, in: .common)
          .autoconnect()
          .sink { [weak self] _ in
            guard let self = self else { return }
            // 現在の最新座標を取り出す
            guard let latest = playerPosition.track.last else { return }

            // 前回送信座標と同じなら何もしない
            if let prev = self.lastSentCoordinate,
               prev.latitude  == latest.latitude,
               prev.longitude == latest.longitude {
                return
            }

            // 座標が変わっていればPOST
            self.lastSentCoordinate = latest
            let steps = self.stepsHK.steps
              
            self.service.postUserStep(
              userID:   userID,
              latitude: latest.latitude,
              longitude: latest.longitude,
              steps:    steps
            )
            .sink(
              receiveCompletion: { comp in
                if case .failure(let err) = comp {
                  print("POST歩数エラー:", err)
                }
              },
              receiveValue: { resp in
                print("POST歩数成功:", resp.result)
                print("緯度:\(latest.latitude),経度:\(latest.longitude),歩数:\(steps)")
              }
            )
            .store(in: &self.cancellables)
          }
          .store(in: &cancellables)
    }

/// ゲーム開始ボタン押下時に呼ぶ
    func startGameLocally() {
        guard var g = game else { return }
        g.statusRaw = GameStatus.inProgress.rawValue
        game = g
    }
    
/// ゲーム終了ボタン押下時に呼ぶ
    func endGameLocally() {
        guard var g = game else { return }
        g.statusRaw = GameStatus.ended.rawValue
        game = g
    }
    
/// type を 0 ↔ 1 で切り替える
    func toggleGameType() {
        guard var g = game else { return }
        g.type = (g.type == 0 ? 1 : 0)
        game = g
    }
}
