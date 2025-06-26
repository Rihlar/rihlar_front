//
//  BlueBtn.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/20.
//

import SwiftUI

struct BlueBtn: View {
    let label: String           // 下に表示するテキスト
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void      // タップ時の処理
    let isBigBtn: Bool          // デカいボタンかどうかのフラグ
    
    var body: some View {
        ZStack {
//            一番外側にある線を表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.subDecorationColor)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: isBigBtn ? 20 : 16)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
//            ボタンの大部分である背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.buttonColor)
                .frame(width: width - 4, height: height - 4)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: isBigBtn ? 20 : 16)
                )
//            うっすらと白がかかったような表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: isBigBtn ? width - 20 : width - 15, height: isBigBtn ? height - 20 : height - 15)
                .clipShape(
//                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
                )
//                グラデーションを別ファイルで作成
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)
            
            Text(label)
                .font(.system(size: isBigBtn ? 20 : 16,weight: .bold))
                .foregroundColor(.white)
                .stroke(color: Color.textColor, width: 0.8)
        }
        .onTapGesture {
            action()
        }
    }
}

// 使用例
//    BlueBtn(
//        label: "ホームに戻る",  // 表示するテキスト
//        width: 160,           // 横幅
//        height: 60,           // 縦幅
//        action: {
//            print("ホームへ戻る") // 何をするか
//        },
//        isBigBtn: false       // デカいボタンかどうか
//    )

#Preview {
    BlueBtn(
        label: "ホームに戻る",  // 表示するテキスト
        width: 160,           // 横幅
        height: 60,           // 縦幅
        action: {
            print("ホームへ戻る") // 何をするか
        },
        isBigBtn: false       // デカいボタンかどうか
    )
    BlueBtn(
        label: "ルーム作成",  // 表示するテキスト
        width: 250,           // 横幅
        height: 150,           // 縦幅
        action: {
            print("ルーム作成") // 何をするか
        },
        isBigBtn: true       // デカいボタンかどうか
    )
    BlueBtn(
        label: "プレイ",  // 表示するテキスト
        width: 160,           // 横幅
        height: 100,           // 縦幅
        action: {
            print("プレイ") // 何をするか
        },
        isBigBtn: true       // デカいボタンかどうか
    )
}
