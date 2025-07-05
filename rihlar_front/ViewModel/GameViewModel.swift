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
    private var cancellables = Set<AnyCancellable>()

    /// デフォルトで Real、テスト時に Mock を渡せる
    init(service: GameServiceProtocol = RealGameService()) {
        self.service = service
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
