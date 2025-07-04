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
/// ゲーム情報を返す既存メソッド
    func fetchGame(id: String) -> AnyPublisher<Game, Error>
    
/// 円データを取得するメソッドを追加
    func getTop3CircleRankingURL(for gameID: String) -> AnyPublisher<[String: TeamCirclesEntity], Error>
}

