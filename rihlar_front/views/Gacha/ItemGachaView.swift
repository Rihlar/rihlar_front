//
//  ItemGachaView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

// MARK: - アイテム用ガチャ画面

struct ItemGachaView: View {
    // アイテム一覧を管理するViewModel（データソース）
    @StateObject var itemViewModel = ItemViewModel()
    
    // ガチャ演出の状態管理クラス（回転や演出の状態を保持）
    @StateObject var animationState = GachaAnimationState()
    
    // 所持コイン（親ビューと双方向バインディング）
    @Binding var totalCoin: Int
    
    // この画面の表示/非表示を管理するバインディング
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景の暗転（演出中は半透明黒にする）
            Color.black.opacity(animationState.isDimmed ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    if animationState.popupShown {
                        // ポップアップを閉じるだけでなく
                        // アニメーション状態も完全リセットする
                        animationState.reset()
                    } else if !animationState.gachaActive && !animationState.characterShown {
                        // ガチャ演出中じゃなければ画面閉じる
                        isPresented = false
                    }
                }
            
            // メインのガチャUI
            VStack(spacing: 16) {
                // 所持コイン表示
                Text("所持コイン: \(totalCoin)")
                    .font(.headline)
                
                // 説明テキスト
                Text("アイテムを手に入れよう！")
                    .font(.title2)
                    .bold()
                
                // ガチャマシン本体の描画
                ZStack {
                    Image("gachagacha")
                        .resizable()
                        .frame(width: 250, height: 450)
                    
                    // カプセルの上下移動
                    Image("BlueCapsule")
                        .offset(y: animationState.offset)
                    
                    // ガチャの火炎演出
                    Image("gachaFlame")
                        .offset(y: 120)
                    
                    // ハンドル画像：回転演出を反映
                    Image("Handle")
                        .resizable()
                        .frame(width: 50, height: 60)
                        .rotationEffect(.degrees(animationState.rotation)) // 回転角度を状態から反映
                        .animation(.easeInOut(duration: 2.0), value: animationState.rotation) // アニメーションを滑らかに
                        .offset(x: -2, y: 88)
                }
                
                // ガチャを引くボタン
                Button("ガチャを引く") {
                    // コインが100以上あるなら消費してアニメ開始
                    if totalCoin >= 100 {
                        totalCoin -= 100
                        animationState.startAnimation(items: itemViewModel.items)
                    }
                }
                .frame(width: 150, height: 55)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                // ボタンの表示不透明度はアニメ状態で制御
                .opacity(animationState.buttonOpacity)
                // コインが不足しているか、アニメ中は無効化
                .disabled(totalCoin < 100 || animationState.buttonOpacity == 0.0)
            }
            .offset(y: 70) // 少し下にずらす
            
            // カプセルの開封演出を表示（演出中かつキャラ詳細が出ていない時）
            if animationState.gachaActive,
               !animationState.characterShown,
               let item = animationState.selectedItem {
                CapsuleOpeningView(
                    item: item,
                    whiteOffset: animationState.whiteCapsuleOffset,
                    blueOffset: animationState.blueCapsuleOffset
                )
            }
            
            // ガチャで出たアイテム詳細をポップアップ表示
            if animationState.popupShown,
               let item = animationState.selectedItem {
                ItemDetailPopup(item: item, isPresented: $animationState.popupShown)
            }
            
            // 白フラッシュ演出（画面全体に白を重ねる）
            if animationState.whiteout {
                Color.white.opacity(animationState.undo)
                    .ignoresSafeArea()
                    .zIndex(100) // 他のUIより前面に出す
            }
        }
    }
}

// プレビュー用のラッパービュー
struct PreviewWrapperView: View {
    // プレビュー用に所持コインを用意
    @State var dummyTotalCoin = 1000
    // プレビュー用の表示状態
    @State var isPresented = true
    
    var body: some View {
        ItemGachaView(
            itemViewModel: ItemViewModel(),
            animationState: GachaAnimationState(),
            totalCoin: $dummyTotalCoin,
            isPresented: $isPresented
        )
    }
}

#Preview {
    PreviewWrapperView()
}
