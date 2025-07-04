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
    
//    円の作成 POST.
    static let createCircleEndpoint = "/gcore/create/circle"
//    上位３位の円 GET ※ゲームIDを含むURL
    static let top3CirclesRankingEndpoint = "/game/ranking/top/{gameId}"
//    自分が歩いた記録 GET
    static let userMovementEndpoint = "/gcore/get/movement/"
//    ランキング GET
    static let topRankingEndpoint = "/gcore/get/top"
}
