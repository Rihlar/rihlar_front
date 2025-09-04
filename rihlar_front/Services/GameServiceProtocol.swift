//
//  GameServiceProtocol.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Combine

//    責務：どこから・どうやってデータを取るかを隠蔽。
//    メリット：実装をモック／本番と入れ替えやすくなる。
/// ゲーム情報取得の振る舞いを定義するプロトコル
protocol GameServiceProtocol {
/// ゲーム情報を返す既存メソッド（自分の参加ゲーム情報）
    func fetchGame() -> AnyPublisher<GameResponse.Game, Error>
/// すべてのゲーム一覧
    func fetchAllGame() -> AnyPublisher<AllGameEntity, Error>
/// ランキング GET
    func fetchTopRanking(UserID: String, GameID: String) -> AnyPublisher<TopRankingEntity, Error>
/// 円データを取得するメソッド
    func getTop3CircleRanking(for gameID: String, userID: String) async throws -> [String: TeamCirclesEntity]
    
/// ユーザーの歩数を取得流メソッド
    func getUserStep(for gameID:String, userID: String) -> AnyPublisher<[UserStep], Error>
    
/// 歩数の最新の１地点だけ送信
    func postUserStep(userID: String, latitude: Double, longitude: Double, steps: Int) -> AnyPublisher<UserStepReportResponse, Error>
    
    func fetchUserProfile() async throws -> UserProfile
}

