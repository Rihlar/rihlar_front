//
//  strokeModifier.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/13.
//

import SwiftUI

// カスタム ViewModifier：任意のViewに縁取り（ストローク）を加えるための構造体
struct StrokeModifier: ViewModifier {
    // 識別用のユニークID（CanvasのSymbol識別に使用）
    private let id = UUID()

    // ストロークの太さ
    private var strokeSize: CGFloat

    // ストロークの色
    private var strokeColor: Color

    // 初期化時にストロークの太さと色を設定
    init(strokeSize: CGFloat, strokeColor: Color) {
        self.strokeSize = strokeSize
        self.strokeColor = strokeColor
    }

    // ViewModifierのメイン処理：条件に応じて修飾を適用
    func body(content: Content) -> some View {
        if strokeSize > 0 {
            // ストロークあり：ストローク付きビューに変換
            strokeBackgroundView(content: content)
        } else {
            // ストロークなし：そのまま表示
            content
        }
    }

    // ストローク背景Viewを生成
    private func strokeBackgroundView(content: Content) -> some View {
        content
            .padding(strokeSize * 2) // ストロークの太さに応じて余白を確保
            .background(strokeView(content: content)) // 背景にストロークを重ねる
    }

    // ストロークを描くView（矩形マスク）
    private func strokeView(content: Content) -> some View {
        Rectangle()
            .foregroundColor(strokeColor) // 背景にストローク色を塗る
            .mask(maskView(content: content)) // ストロークの形にマスクする
    }

    // ストロークの形をマスクとして描画する処理
    private func maskView(content: Content) -> some View {
        Canvas { context, size in
            // アルファ値がある程度以上の部分だけを描画対象に
            context.addFilter(.alphaThreshold(min: 0.01))
            
            // 描画レイヤーにシンボルを描画
            context.drawLayer { ctx in
                if let resolvedView = context.resolveSymbol(id: id) {
                    // 中央に描画
                    ctx.draw(resolvedView, at: .init(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            // シンボル定義：元のコンテンツにぼかしをかけてストロークの境界を拡張
            content
                .tag(id)
                .blur(radius: strokeSize) // ぼかしの半径 = ストロークの太さ
        }
    }
}

// View拡張：任意のViewに対して .stroke(color:width:) が使えるようにする
extension View {
    public func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}


//  このコードの使い方（例）
//  Text("Hello, SwiftUI!")
//    .foregroundColor(.white)
//    .stroke(color: .blue, width: 2) // 青い縁取りが表示される

