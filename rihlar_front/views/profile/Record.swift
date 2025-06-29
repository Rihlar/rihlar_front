//
//  Record.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

// 実績情報のモデル定義
struct Record: Codable, Identifiable {
    var id: Int                 // 実績のID
    var title: String
}
