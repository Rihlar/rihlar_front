//
//  MenuItem.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

/// メニュー内のアイコン or アイコン＋ラベル付き行を再利用可能にしたコンポーネント
struct MenuItem: View {
    let systemName: String         // SF Symbols の名前
    let label: String             // 文字列ラベル
    let action: () -> Void         // タップ時のアクションをクロージャで受け取る
    
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // タップ時に背景がうっすら黒くなるハイライト
            RoundedRectangle(cornerRadius: 10)
                .fill(isPressed ? Color.black.opacity(0.1) : Color.clear)
                .frame(width: 220, height: 60, alignment: .leading)
            
            HStack(spacing: 12) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 20)
                    .foregroundColor(Color("TextColor"))
                
                Text(label)
                    .foregroundColor(Color("TextColor"))
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
            }
            .frame(width: 220, height: 60, alignment: .leading)
        }
        // DragGesture(minimumDistance:0) で tap の「押し込み／離し」を検知
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    action()  // ここでクロージャを呼び出し
                }
        )
    }
}
