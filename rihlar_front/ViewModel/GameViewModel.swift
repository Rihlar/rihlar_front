//
//  GameViewModel.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Combine
import Foundation
import CoreLocation

//    責務：View 側に必要なデータを保持し、サービスからの取得・エラーも管理。
//    ポイント：Combine を使って非同期を扱い、UI へのバインディングは @Published。
final class GameViewModel: ObservableObject {
    @Published var game: [Game] = []
    @Published var circlesByTeam: [TeamCircles] = []
    @Published var userStepByTeam: [UserStep] = []
    @Published var isLoadingGame = false
    @Published var isLoadingCircles = false
    @Published var isLoadingUserStep = false
    @Published var errorMessage: String?
    // 種別ごとの配列
    @Published private(set) var systemGames: [Game] = []
    @Published private(set) var adminGames:  [Game] = []
    //    今ビューで使う単一のゲーム
    @Published var currentGame:   Game?
    
    private let service: GameServiceProtocol
    private let stepsHK: StepsHealthKit
    private var cancellables = Set<AnyCancellable>()
    private var lastSentCoordinate: CLLocationCoordinate2D?
    
    /// デフォルトで Real、テスト時に Mock を渡せる
    init(service: GameServiceProtocol = RealGameService(), stepsHK: StepsHealthKit = StepsHealthKit()) {
        self.service = service
        self.stepsHK = stepsHK
        fetchGame(by: "GameID")
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
            } receiveValue: { [weak self] games in
                guard let self = self else { return }
                self.game = games
                self.systemGames = games.filter { $0.isSystemGame }
                self.adminGames  = games.filter { $0.isAdminGame  }
                
                self.currentGame = self.adminGames.first
                
                print("[DEBUG] fetched game:", game)
                print("[DEBUG] fetched currentGame:", currentGame)
                
                self.reloadOverlaysAndSteps()
            }
            .store(in: &cancellables)
    }
    
//    currentGame が変わるたびに呼び出すヘルパー
    private func reloadOverlaysAndSteps() {
        guard let game = currentGame else { return }
        let uid = "userid-79541130-3275-4b90-8677-01323045aca5"
        fetchCircles(for: game.gameID, userID: uid)
        fetchUserStep(for: game.gameID, userID: uid)
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
                    //                    print("🌐 fetchUserStep レスポンス内容: \(entities)")
                    
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
    
    /// system ↔ admin 切り替え
     func toggleCurrentGameType() {
       guard let before = currentGame else { return }
       // モード切り替え
       if before.isSystemGame, let next = adminGames.first {
         currentGame = next
       } else if before.isAdminGame, let next = systemGames.first {
         currentGame = next
       }

       // 🔄 切り替え後のゲームIDで再フェッチ
       if let after = currentGame {
         let gameID = after.gameID
         let userID = "userid-79541130-3275-4b90-8677-01323045aca5"
         fetchCircles(for: gameID, userID: userID)
         fetchUserStep(for: gameID, userID: userID)
       }

       print("[GameViewModel] currentGame changed to:", currentGame?.gameID ?? "nil")
     }
    
    /// ゲーム開始ボタン押下時に呼ぶ
    func startGameLocally() {
        guard var g = currentGame else { return }
        g.statusRaw = GameStatus.inProgress.rawValue
        currentGame = g
        replace(in: &systemGames, or: &adminGames, with: g)
    }
    
    /// ゲーム終了ボタン押下時に呼ぶ
    func endGameLocally() {
        guard var g = currentGame else { return }
        g.statusRaw = GameStatus.ended.rawValue
        currentGame = g
        replace(in: &systemGames, or: &adminGames, with: g)
    }
    
    private func replace(in sys: inout [Game], or adm: inout [Game], with updated: Game) {
        if let idx = sys.firstIndex(where: { $0.gameID == updated.gameID }) {
            sys[idx] = updated
        }
        if let idx = adm.firstIndex(where: { $0.gameID == updated.gameID }) {
            adm[idx] = updated
        }
    }
}
