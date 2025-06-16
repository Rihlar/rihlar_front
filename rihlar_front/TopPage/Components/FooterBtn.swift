//
//  FooterBtn.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/16.
//

import SwiftUI

struct FooterBtn: View {
    let iconName: String        // アイコン画像名
    let label: String           // 下に表示するテキスト
    let action: () -> Void      // タップ時の処理
    let padding: EdgeInsets     // 配置調整用

    var body: some View {
        VStack(spacing: -20) {
            ZStack {
                Image(iconName)
                    .zIndex(10)

                Circle()
                    .fill(Color("footerbg"))
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.black.opacity(0.25), radius: 5)
            }

            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .stroke(color: Color("TextBtnColor"), width: 0.8)
                .zIndex(1)
        }
        .padding(padding)
        .onTapGesture {
            action()
        }
    }
}
