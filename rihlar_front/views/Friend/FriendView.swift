//
//  FriendView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/30.
//

import SwiftUI

// フレンド画面
struct FriendView: View {
    var body: some View {
        // フレンド追加ボタン
        Button {
            print("フレンドを追加するよ")
        } label: {
            BlueBtn(
                label: "フレンドを追加",
                width: 160,
                height: 60,
                action: {
                    print("フレンド追加ページへ")
                },
                isBigBtn: false
            )
        }

    }
}

#Preview {
    FriendView()
}
