//
//  Item.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/28.
//

// アイテムの情報を表す構造体。将来的にCodableにすればAPIレスポンスと連携できる。
struct Item: Identifiable {
    var id: Int             // アイテムID
    var name: String        // アイテム名
    var count: Int          // 所持数
    let iconName: String    // アイテムのアイコン
}
