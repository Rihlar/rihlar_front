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
    @Published var game: GameResponse.Game?
    @Published var AllGame: AllGameEntity?
    @Published var TopRanking: TopRankingEntity?
    @Published var circlesByTeam: [TeamCircles] = []
    @Published var userStepByTeam: [UserStep] = []
    @Published var isLoadingGame = false
    @Published var isLoadingCircles = false
    @Published var isLoadingUserStep = false
    @Published var errorMessage: String?
    // 種別ごとの配列
    @Published var systemGames: GameResponse.systemGame?
    @Published var adminGames: GameResponse.adminGame?
//    trueだったらadminGame falseだったらsystemGame
    @Published var currentGameIsAdmin: Bool
    //    今ビューで使う単一のゲーム
//    @Published private(set) var currentGame: GameResponse.Game
    // プロフィール取得結果を保持するプロパティ
    @Published var profile: String
    @Published var profileError: String?
    
    private let service: GameServiceProtocol
    private let stepsHK: StepsHealthKit
    private var cancellables = Set<AnyCancellable>()
    private var lastSentCoordinate: CLLocationCoordinate2D?
    
    init(service: GameServiceProtocol = RealGameService(), stepsHK: StepsHealthKit = StepsHealthKit()) {
        self.service = service
        self.stepsHK = stepsHK
        self.game                = nil
        self.AllGame             = nil
        self.TopRanking          = nil
        self.systemGames         = nil
        self.adminGames          = nil
        self.currentGameIsAdmin  = false
        self.profile             = ""
        
        fetchGame(by: "GameID")
        getAllGames()
    }
    
    var currentGameID: String? {
        if currentGameIsAdmin {
            return adminGames?.GameID
        } else {
            return systemGames?.GameID
        }
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
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.game = response

                // system/admin に分けて格納
                self.systemGames = response.system
                self.adminGames  = response.admin
                
                self.currentGameIsAdmin = response.IsAdminJoined
                
                print("[DEBUG] fetched systemgame:", systemGames)
                print("[DEBUG] fetched adminGames:", adminGames)
                
                self.reloadOverlaysAndSteps()
            }
            .store(in: &cancellables)
    }
    
    func getAllGames() {
        errorMessage = nil
        service.fetchAllGame()
            .sink{ [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                    print("❌ エラー: \(err.localizedDescription)")
                } else {
                    print("✅ 通信完了")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                print("📦 取得したゲーム一覧: \(response.Data)")
                
                self.AllGame = response
            }
            .store(in: &cancellables)
    }
    
    func getTopRanking(UserID: String, gameID: String) {
        errorMessage = nil
        service.fetchTopRanking(UserID: UserID, GameID: gameID)
            .sink{ [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                    print("❌ getTopRankingエラー: \(err.localizedDescription)")
                } else {
                    print("✅ 通信完了")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
//                print("📦 ランキング GET.: \(response)")
                
                self.TopRanking = response
            }
            .store(in: &cancellables)
    }
    
//    currentGame が変わるたびに呼び出すヘルパー
    private func reloadOverlaysAndSteps() {
        guard let gameID = currentGameID else {
            print("❌ currentGameID が nil です")
            return
        }
        
        guard !profile.isEmpty else {     // ← nil ではなく空文字をチェック
            print("❌ profile が未設定です")
            return
        }
        let userID = profile
        print("✅ 両方の値が取得できました - gameID: \(gameID), userID: \(userID)")
        fetchCircles(for: gameID, userID: userID)
        fetchUserStep(for: gameID, userID: userID)
    }
    
    /// 円情報だけ取得
    func fetchCircles(for gameID: String, userID: String) {
        isLoadingCircles = true
        errorMessage = nil
        
        Task {
            do {
                let respDict = try await service.getTop3CircleRanking(for: gameID, userID: userID)
                
                await MainActor.run {
                    print("✅ fetchCircles 成功")
//                    print("🌐 fetchCircles レスポンス内容: \(respDict)")
                    
                    // 辞書 → [TeamCircles] へ変換
                    self.circlesByTeam = respDict.map { key, entity in
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
                    
                    self.isLoadingCircles = false
                }
                
            } catch let error as URLError {
                await MainActor.run {
                    switch error.code {
                    case .notConnectedToInternet:
                        self.errorMessage = "インターネット接続がありません"
                    case .timedOut:
                        self.errorMessage = "リクエストがタイムアウトしました"
                    case .userAuthenticationRequired:
                        self.errorMessage = "認証が必要です"
                    default:
                        self.errorMessage = "ネットワークエラー: \(error.localizedDescription)"
                    }
                    print("❌ fetchCircles URLError: \(self.errorMessage ?? "")")
                    self.isLoadingCircles = false
                }
                
            } catch {
                await MainActor.run {
                    print("❌ fetchCircles エラー: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoadingCircles = false
                }
            }
        }
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
        func bindPlayerPositionUpdates(for userID: String, playerPosition: PlayerPosition) {
            let positionPublisher = playerPosition.$track
//                .print("[PP]")
//                .dropFirst()                            // 初回シード除外
                .compactMap { $0.last }                 // 配列の最後の１点だけ
                .removeDuplicates { a, b in
                    a.latitude == b.latitude && a.longitude == b.longitude
                }
                .throttle(for: .seconds(10), scheduler: RunLoop.main, latest: true)
                .eraseToAnyPublisher()
            
            positionPublisher
                .sink { [weak self] latest in
                    guard let self = self else { return }
                    
                    let steps = self.stepsHK.steps // ここは HealthKit 等から実際の歩数を取得してください
                    print("緯度:\(latest.latitude),経度:\(latest.longitude),歩数:\(steps)")
    
                    let postPub = self.service.postUserStep(
                        userID:   userID,
                        latitude: latest.latitude,
                        longitude: latest.longitude,
                        steps:    steps
                    )
                    
                    postPub
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { comp in
                                if case .failure(let err) = comp {
                                    print("POST歩数エラー:", err)
                                    
                                    // URLError の詳細情報を確認
                                    if let urlError = err as? URLError {
//                                        print("URLError code: \(urlError.code.rawValue)")
//                                        print("URLError description: \(urlError.localizedDescription)")
//                                        print("URLError userInfo: \(urlError.userInfo)")
                                        
                                        // HTTPレスポンスがあれば確認
                                        if let httpResponse = urlError.userInfo[NSURLErrorFailingURLErrorKey] as? HTTPURLResponse {
//                                            print("HTTP Status Code: \(httpResponse.statusCode)")
                                        }
                                    }
                                    
                                    // NSErrorとしての詳細も確認
                                    let nsError = err as NSError
                                    print("Error domain: \(nsError.domain)")
                                    print("Error code: \(nsError.code)")
                                    print("Error userInfo: \(nsError.userInfo)")
                                }
                            },
                            receiveValue: { resp in
                                // ===== 新レスポンス構造に合わせたログ =====
                                // IsSyetemSuccess（APIのスペルに合わせる）
                                let sysOK = resp.isSystemSuccess
                                // 先頭要素のメッセージやステータスを例示
                                let first = resp.adminGames.first
                                let msg = first?.message ?? "-"
                                let status = first?.status ?? -1

                                print("POST歩数成功: \(resp)")
                                print("緯度:\(latest.latitude),経度:\(latest.longitude),歩数:\(steps)")
                            }
                        )
                        .store(in: &self.cancellables)
                }
                .store(in: &cancellables)
        }
    
//    ユーザープロフィール取得を呼び出す
    func loadUserProfile() {
        Task {
            do {
                let profile = try await fetchUserProfile()
                await MainActor.run {
                    self.profile = profile.id
                }
            } catch {
                await MainActor.run {
                    self.profileError = error.localizedDescription
                }
            }
        }
    }
    
    /// system ↔ admin 切り替え
    func toggleCurrentGameType() {
        // game が nil なら早期リターン
        guard let game = game else { return }
        // 参加していなければ切り替え不可
//        guard game.IsAdminJoined else { return }
        // フラグを反転
        currentGameIsAdmin.toggle()
        // 切り替え後の GameID で再フェッチ
        reloadOverlaysAndSteps()
        print("[GameViewModel] 切り替え後のモード isAdmin=", currentGameIsAdmin, " gameID=", currentGameID ?? "nil")
    }
    
    /// ゲーム開始ボタン押下時に呼ぶ
//    func startGameLocally() {
//        guard var g = currentGame else { return }
//        g.statusRaw = GameStatus.inProgress.rawValue
//        currentGame = g
//        replace(in: &systemGames, or: &adminGames, with: g)
//    }
//    
//    /// ゲーム終了ボタン押下時に呼ぶ
//    func endGameLocally() {
//        guard var g = currentGame else { return }
//        g.statusRaw = GameStatus.ended.rawValue
//        currentGame = g
//        replace(in: &systemGames, or: &adminGames, with: g)
//    }
//    
//    private func replace(in sys: inout [Game], or adm: inout [Game], with updated: Game) {
//        if let idx = sys.firstIndex(where: { $0.gameID == updated.gameID }) {
//            sys[idx] = updated
//        }
//        if let idx = adm.firstIndex(where: { $0.gameID == updated.gameID }) {
//            adm[idx] = updated
//        }
//    }
}
