//
//  ItemGachaView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

// MARK: - アイテム用ガチャ画面

struct ItemGachaView: View {
    @StateObject var itemViewModel = ItemViewModel()
    @StateObject var animationState = GachaAnimationState()
    @Binding var totalCoin: Int
    
    var body: some View {
        ZStack {
            // 背景の暗転
            Color.black.opacity(animationState.isDimmed ? 0.3 : 0)
                .ignoresSafeArea()
            
            // 上部テキスト＆本体
            VStack(spacing: 16) {
                Text("所持コイン: \(totalCoin)")
                    .font(.headline)
                Text("アイテムを手に入れよう！")
                    .font(.title2)
                    .bold()
                
                // ガチャマシン
                ZStack {
                    Image("gachagacha")
                        .resizable()
                        .frame(width: 250, height: 450)
                    Image("BlueCapsule")
                        .offset(y: animationState.offset)
                    Image("gachaFlame")
                        .offset(y: 120)
                    Image("Handle")
                        .resizable()
                        .frame(width: 50, height: 60)
                        .rotationEffect(.degrees(animationState.rotation))
                        .offset(x: -2, y: 88)
                }
                
                // ガチャを引くボタン
                Button("ガチャを引く") {
                    if totalCoin >= 1000 {
                        totalCoin -= 1000
                        animationState.startAnimation(items: itemViewModel.items)
                    }
                }
                .frame(width: 150, height: 55)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .opacity(animationState.buttonOpacity)
                .disabled(totalCoin < 1000 || animationState.buttonOpacity == 0.0)
            }
            .offset(y: 70)
            
            // 開封演出（カプセル）
            if animationState.gachaActive, let item = animationState.selectedItem {
                CapsuleOpeningView(
                    item: item,
                    whiteOffset: animationState.whiteCapsuleOffset,
                    blueOffset: animationState.blueCapsuleOffset
                )
            }

            // 完全に表示されたアイテム詳細
            if animationState.characterShown, let item = animationState.selectedItem {
                VStack(spacing: 8) {
                    Image(item.iconName)
                        .resizable()
                        .frame(width: 300, height: 300)
                        .offset(y: 120)
                    Text(item.name)
                        .font(.title)
                        .bold()
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            
            // フラッシュ演出
            if animationState.whiteout {
                Color.white.opacity(animationState.undo)
                    .ignoresSafeArea()
                    .zIndex(100)
            }
        }
    }
}

#Preview {
    PreviewWrapperView()
}

struct PreviewWrapperView: View {
    @State var dummyTotalCoin = 1000
    
    var body: some View {
        ItemGachaView(
            itemViewModel: ItemViewModel(),
            animationState: GachaAnimationState(),
            totalCoin: $dummyTotalCoin
        )
    }
}
