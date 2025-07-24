//
//  ItemGachaView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

// MARK: - アイテム用ガチャ画面

struct ItemGachaView: View {
    @ObservedObject var router: Router
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    // アイテム一覧を管理するViewModel（データソース）
    @StateObject var itemViewModel = ItemViewModel()
    
    // ガチャ演出の状態管理クラス（回転や演出の状態を保持）
    @StateObject var animationState = GachaAnimationState()
    
    // 所持コイン（親ビューと双方向バインディング）
    @Binding var totalCoin: Int
    
    // この画面の表示/非表示を管理するバインディング
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack (alignment: .bottom){
            Color(Color.backgroundColor)
                .ignoresSafeArea()
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
                // 説明テキスト
                Text("アイテムガチャ")
                    .font(.headline)
                    .bold()

                // 所持コイン表示
                ZStack {
                    HStack{
                        Image("coin")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:40, height: 32)
                        Spacer()
                        Text("\(totalCoin)")
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWeight(.heavy)
                            .padding(.trailing, 8)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.mainDecorationColor, lineWidth: 8)
                    )
                    .cornerRadius(20)
                }
                .frame(maxWidth: 200)
                
                OrangeBtn(
                    label: "ガチャを引く",
                    width: 160,
                    height: 60,
                    action: {
                        if totalCoin >= 100 {
                            totalCoin -= 100
                            animationState.startAnimation(items: itemViewModel.items)
                        }
                    },
                    isBigBtn: false
                )
                .opacity(animationState.buttonOpacity)
                .disabled(totalCoin < 100 || animationState.buttonOpacity == 0.0)
                
                // ガチャマシン本体の描画
                ZStack {
                    Image("gachagacha")
                        .resizable()
                        .frame(width: 254, height: 449)
                    
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
                
                
            }
            .offset(y: 70) // 少し下にずらす
            .padding(.bottom, 200)
            
            ZStack {
                // カプセルの開封演出を表示（演出中かつキャラ詳細が出ていない時）
                if animationState.gachaActive,
                   !animationState.characterShown,
                   let item = animationState.selectedItem {
                    CapsuleOpeningView(
                        item: item,
                        whiteOffset: animationState.whiteCapsuleOffset,
                        blueOffset: animationState.blueCapsuleOffset
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
                // ガチャで出たアイテム詳細をポップアップ表示
                if animationState.popupShown,
                   let item = animationState.selectedItem {
                    ItemDetailPopup(item: item, isPresented: $animationState.popupShown)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.scale)
                }
            }
            
            // 白フラッシュ演出（画面全体に白を重ねる）
            if animationState.whiteout {
                Color.white.opacity(animationState.undo)
                    .ignoresSafeArea()
                    .zIndex(100) // 他のUIより前面に出す
            }
            
            
            
            if isShowMenu {
                Color.white.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Menu(router: router)
                    .transition(
                        .move(edge: .trailing)
                        .combined(with: .opacity)
                    )
            }
            
            
            BottomNavigationBar(
                router: router,
                isChangeBtn: isChangeBtn,
                onCameraTap: {
                    router.push(.camera)
                },
                onMenuTap: {
                    //   ボタンの見た目切り替えは即時（アニメなし）
                    isChangeBtn.toggle()
                    
                    //　　メニュー本体の表示はアニメーション付き
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
            
        }
        .padding(.horizontal)
    }
}

// プレビュー用のラッパービュー
struct GachaWrapperView: View {
    @ObservedObject var router: Router
    
    // プレビュー用に所持コインを用意
    @State var dummyTotalCoin = 1000
    // プレビュー用の表示状態
    @State var isPresented = true
    
    var body: some View {
        ItemGachaView(
            router: router,
            itemViewModel: ItemViewModel(),
            animationState: GachaAnimationState(),
            totalCoin: $dummyTotalCoin,
            isPresented: $isPresented
        )
    }
}

#Preview {
    GachaWrapperView(router:Router())
}
