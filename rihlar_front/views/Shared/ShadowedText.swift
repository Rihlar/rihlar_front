//
//  ShadowedText.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI

// 黒縁付きのテキストを表示するようのコンポーネント
// 複数のテキストを重ねることで影を作成している

struct ShadowedText: View {
    
    // 表示する文字列
    let text: String
    // テキストフォント
    let font: Font
    // メインの文字の色(デフォルトは白)
    let foregroundColor: Color
    // 黒縁の色（デフォルトはtextColor）
    let shadowColor: Color
    // 影を重ねる範囲
    let shadowRadius: Int
    // テキストの垂直方向の微調整（上下用）
    let offsetY: CGFloat
    
    init(
        _ text: String,
        font: Font = .headline,
        foregroundColor: Color = .white,
        shadowColor: Color = Color.textColor,
        shadowRadius: Int = 2,
        offsetY: CGFloat = 0
    ) {
        self.text = text
        self.font = font
        self.foregroundColor = foregroundColor
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.offsetY = offsetY
    }
    
    var body: some View {
        ZStack {
            // 黒縁用のテキストをずらして重ねる
            ForEach(-shadowRadius...shadowRadius, id: \.self) { x in
                ForEach(-shadowRadius...shadowRadius, id: \.self) { y in
                    if x != 0 || y != 0 {
                        Text(text)
                            .font(font)
                            .foregroundColor(shadowColor)
                            .offset(x: CGFloat(x), y: CGFloat(y) + offsetY)
                    }
                }
            }
            // メインの文字を中央に配置
            Text(text)
                .font(font)
                .foregroundColor(foregroundColor)
                .offset(y: offsetY)
        }
    }
}
