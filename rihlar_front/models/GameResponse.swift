//
//  GameResponse.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/08.
//

import Foundation

/// API から返ってくる「Data」配列全体を受け取るラッパー
struct GameResponse: Codable {
    let data: [Game]    // JSON の "Data" キーに対応
    // JSON 側のキー名が大文字なので CodingKeys でマッピング
    private enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

