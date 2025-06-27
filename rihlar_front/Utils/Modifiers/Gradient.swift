//
//  Gradient.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/19.
//

import SwiftUI

extension View {
    /// 任意の Shape をマスクにして、角度と色を指定した LinearGradient を overlay します。
    ///
    /// - Parameters:
    ///   - mask: グラデーションをマスクする Shape（clipShape と同じ形状を渡す）
    ///   - colors: グラデーションに使う色の配列
    ///   - angle: グラデーションの方向（度数法）
    /// - Returns: グラデーションを重ねた View
    func overlayLinearGradient<Mask: Shape>(
        mask: Mask,
        colors: [Color],
        angle: Angle
    ) -> some View {
        // 角度から start/end の UnitPoint を計算
        let rad = angle.radians
        let start = UnitPoint(
            x: 0.5 - cos(rad) / 2,
            y: 0.5 - sin(rad) / 2
        )
        let end = UnitPoint(
            x: 0.5 + cos(rad) / 2,
            y: 0.5 + sin(rad) / 2
        )

        return overlay(
            mask
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: start,
                        endPoint: end
                    )
                )
        )
    }
}

//　使用例
//
//       .overlayLinearGradient(
//            mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50), // クリップ形状と同じ
//            colors: [
//                Color.white.opacity(1.0),　// 左側は白100%
//                Color.white.opacity(0.0)　// 右側は白0%
//            ],
//            angle: .degrees(77)　 // 77度
//        )
