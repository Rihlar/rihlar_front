//
//  CapsuleOpeningView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

// MARK: - カプセルの開封アニメーション＋アイテム表示ビュー

struct CapsuleOpeningView: View {
    let item: Item
    let whiteOffset: CGSize
    let blueOffset: CGSize
    
    var body: some View {
        ZStack {
            // アイテム表示（カプセル内）
            Image(item.iconName)
                .resizable()
                .frame(width: 120, height: 120)
                .offset(y: -30)
            
            // カプセルの左右の蓋
            HStack(spacing: 0) {
                Image("WhiteHalfCapsule")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(whiteOffset)
                Image("BlueHalfCapsule")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(blueOffset)
            }
        }
    }
}
