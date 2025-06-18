//
//  RoundedCornerShape.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

// SwiftUI の View に使えるカスタムの角丸形状を定義
struct RoundedCornerShape: Shape {
//    どの角を丸めるか（例: .topLeft, .bottomRight など）
    var corners: UIRectCorner

//    丸める半径（角の丸さ）
    var radius: CGFloat

//    この Shape がどのようなパス（形）を描くかを定義
    func path(in rect: CGRect) -> Path {
//        UIBezierPath を使って、特定の角だけ丸めたパスを作る
        let path = UIBezierPath(
            roundedRect: rect,                  // 四角形の範囲
            byRoundingCorners: corners,        // 丸める角を指定（例: [.topLeft, .bottomRight]）
            cornerRadii: CGSize(width: radius, height: radius) // 丸めるサイズ
        )

//        UIBezierPath を SwiftUI の Path に変換して返す
        return Path(path.cgPath)
    }
}

// 使用例
// RoundedRectangle(cornerRadius: 0) // → 角丸の四角を角丸なしで描画
//    .fill(Color("menuColor"))
//    .frame(width: 320, height: 494)
//    .clipShape(
//        この部分で角丸を自作のShapeで定義
//        RoundedCornerShape(corners: [.bottomLeft], radius: 20)
//    )
//    .shadow(color: Color.black.opacity(0.25), radius: 5)

// 例：左上[.topLeft], 右上[.topRight], 左下[.bottomLeft] 右下[.bottomRight]
// 組み合わせも可 → [.topLeft, .bottomRight]
