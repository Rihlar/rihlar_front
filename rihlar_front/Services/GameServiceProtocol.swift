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
    func fetchGame(id: String) -> AnyPublisher<Game, Error>
}

