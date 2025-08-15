//
//  BaseURL.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/04.
//

import Foundation

/// 環境設定（APIのエンドポイントなど）を定義する構造体
struct APIConfig {
    static let baseURL = URL(string: "https://rihlar-test.kokomeow.com")!
    static let stagingBaseURL = URL(string: "https://rihlar-stage.kokomeow.com")!
    // ユーザー情報
    static let userInfoEndpoint = "/auth/me"
    // ソロランキングのAPI（ゲームIDが必要！）
    static func soloRanking(gameId: String, environment: APIEnvironment = .staging) -> URL {
        return environment.baseURL.appendingPathComponent("game/ranking/solo/top10/\(gameId)")
    }
    // 自分のゲーム参加情報を取るAPIのURL
    static func gameUserInfoURL(environment: APIEnvironment = .staging) -> URL {
        return environment.baseURL.appendingPathComponent("game/info/self")
    }
    //    円の作成 POST.
    static let createCircleEndpoint = "/gcore/create/circle"
    //    上位３位の円 GET ※ゲームIDを含むURL
    static let top3CirclesRankingEndpoint = "/game/ranking/top/{gameId}"
    //    自分が歩いた記録 GET
    static let userMovementEndpoint = "/gcore/get/movement"
    //    ランキングTOP10  (ソロ) GET
    static let topRankingEndpoint = "/game/ranking/solo/top10/{game_uuid}"
    //    歩いたデータを送る POST
    static let sendUserStepEndpoint = "/gcore/report/movement"
    //    ユーザーのプロフィール　GET
    static let userProfile = "/user/profile"
    //    写真取得
    static let photo = "/photos"
//    ゲーム情報取得
    static let gameInformation = "/game/info/self"
//    すべてのゲーム一覧
    static let AllGame = "/game/allgames"
}

enum APIEnvironment {
    case test
    case staging
    
    var baseURL: URL {
        switch self {
        case .test:
            return URL(string: "https://rihlar-test.kokomeow.com")!
        case .staging:
            return URL(string: "https://rihlar-stage.kokomeow.com")!
        }
    }
}
