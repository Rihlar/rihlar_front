//
//  TopPageInProgressView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import SwiftUI
import CoreLocation

struct TopPageInProgressView: View {
    @ObservedObject var vm: GameViewModel
    @ObservedObject var router: Router
    //    プレイヤーに追従モードか自由に移動できるかなどの処理をしている関数
    @StateObject private var playerPosition = PlayerPosition()
    //    地図上に表示する円の座標を表示するためのから配列
    @State private var circles: [CircleData] = []
    //    カメラ画面の表示非表示を制御
    @State private var isShowCamera = false
    //    メニューの表示非表示を制御
    @State private var isShowMenu = false
    //    メニューボタンと戻るボタンの制御
    @State private var isChangeBtn = false
    let game: Game
    
    var body: some View {
        ZStack {
            // mapkitを使用した地図表示
            CircleMap(playerPosition: playerPosition, circlesByTeam: vm.circlesByTeam)
                .ignoresSafeArea()
                .onAppear {
                    vm.fetchCircles(for: "テスト用Circleデータ")
                }
                .blur(radius: isShowMenu ? 10 : 0)
                .animation(.easeInOut, value: isShowMenu)
            
            VStack {
                Header(
                    vm: vm,
                    game: game
                )
                
                Spacer()
            }
            .blur(radius: isShowMenu ? 10 : 0)
            .animation(.easeInOut, value: isShowMenu)
            
            // ─────────── 「陣取りスタート！」のオーバーレイ ───────────
            if router.didStartFromLoading {
                Text("陣取りスタート！")
                    .font(.system(size: 32,weight: .bold))
                    .foregroundColor(.white)
                    .stroke(color: Color(hex: "#E85B5B"), width: 0.8)
                    .transition(.opacity)
                    .onAppear {
                        // 2秒後にフラグをリセットして非表示に
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation {
                                router.didStartFromLoading = false
                            }
                        }
                    }
            }
            
            if isShowMenu {
                Color.white.opacity(0.1)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Menu(router: router)
                    .transition(
                        .move(edge: .trailing)
                        .combined(with: .opacity)
                    )
                    .zIndex(10)
            }
            
            VStack(spacing: 0) {
                Spacer()
                //                    現在地に戻るボタン
                //                    デザインは後回しにしているので変更する
                HStack {
                    Button {
                        playerPosition.resumeFollow()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .frame(width: 48, height: 48)
                            .foregroundStyle(Color.white.opacity(0.8))
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .frame(width: 48, height: 48)
                    }
                    .opacity(0)
                }
                Footer (
                    router: router,
                    isChangeBtn: isChangeBtn,
                    //                            カメラ画面を表示するためのflag
                    onCameraTap: {
                        router.push(.camera)
                    },
                    //                            メニューを表示するためのflag
                    onMenuTap: {
                        //                        ボタンの見た目切り替えは即時（アニメなし）
                        isChangeBtn.toggle()
                        
                        //                        メニュー本体の表示はアニメーション付き
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowMenu.toggle()
                        }
                    },
                    vm: vm,
                    game: game,
                    gameType: vm.game?.type ?? 0
                )
            }
            .zIndex(1)
        }
        .animation(.easeInOut, value: router.didStartFromLoading)
    }
}

