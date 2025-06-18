//
//  Colors.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/16.

// カラー定義ファイル

import SwiftUI

extension Color {
    // 16進数のカラーコードからColorを生成するイニシャライズを追加
    init(hex hexString: String) {
        // 数字だけを取り出す
        let hex = hexString.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        // 整数に変換
        Scanner(string: hex).scanHexInt64(&rgb)
        // 赤・緑・青それぞれの成分を取り出し、0〜1の範囲に正規化
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        // SwiftUIのColorのイニシャライザを使ってRGBカラーを作成
        self.init(red: r, green: g, blue: b)
    }
    
    // カラーの定義
    static let buttonColor = Color(hex: "#A8EAF0")          // ボタン
    static let mainDecorationColor = Color(hex: "＃98BA87") // メイン装飾
    static let subDecorationColor = Color(hex: "＃FEE075")  // サブ装飾
    static let textColor = Color(hex: "#4F4936")            // 文字
    static let mainShadowColor = Color(hex: "#87A578")      // メイン装飾影
    static let buttonFrameColor = Color(hex: "#87B6BA")     // ボタンの枠
    static let backgroundColor = Color(hex: "#EEEBE1")      // 背景
    static let linkColor = Color(hex: "#3D8BFF")            // リンク
}
