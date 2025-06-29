//
//  Record.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

// 実績情報のモデル定義
struct Record: Codable, Identifiable {
    let id: Int                 // 実績のID
    let title: String           // 実績名
    let description: String     // 実績の説明
    let imageUrl: String        // 実績アイコン
    
}
