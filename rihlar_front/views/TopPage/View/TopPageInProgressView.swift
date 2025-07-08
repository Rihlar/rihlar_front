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
    //    ゲームが終了しているかのフラグ
    @State private var isGameOverFlag = false
    
    @State private var timeString: String = ""
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject private var hk = StepsHealthKit()
    let currentUserTeamID: String = "teamid-32f5eb5f-534b-439e-990e-349e52d70970"
    
    var body: some View {
        ZStack {
            // mapkitを使用した地図表示
            CircleMap(
                playerPosition: playerPosition,
                circlesByTeam: vm.circlesByTeam,
                userStepByTeam: vm.userStepByTeam,
                currentUserTeamID: currentUserTeamID,
                gameStatus: GameStatus(rawValue: game.statusRaw) ?? .notStarted
            )
                .ignoresSafeArea()
                .onAppear {
                    vm.fetchCircles(for: game.gameID, userID: "userid-79541130-3275-4b90-8677-01323045aca5")
                    vm.fetchUserStep(for: game.gameID, userID: "userid-79541130-3275-4b90-8677-01323045aca5")
                    vm.bindPlayerPositionUpdates(for: "userid-79541130-3275-4b90-8677-01323045aca5", playerPosition: playerPosition)
                }
                .onChange(of: vm.userStepByTeam) { steps in
                    let apiCoords = steps.map { CLLocationCoordinate2D(
                        latitude: $0.latitude,
                        longitude: $0.longitude
                    ) }
                    playerPosition.seedTrack(with: apiCoords)
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
            
//            見た目は無いけど、remainingTimeString の変化を監視してフラグを立てる）
            Color.clear
                .onReceive(timer) { _ in
                  let newValue = remainingTimeString(until: game.endTime)
                  timeString = newValue
                }
                .onChange(of: timeString) { newValue in
                  if newValue == "終了" {
                    isGameOverFlag = true
                  }
                }
            
            if isGameOverFlag && game.status == .inProgress {
                ModalView(
                    isModal: $isGameOverFlag,
                    titleLabel: "結果",
                    closeFlag: true,
                    action: {
                        isGameOverFlag = false
                        vm.endGameLocally()
                        
                    },
                    content: {
                    VStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("あなたの順位は")
                                .font(.system(size: 14,weight: .light))
                                .foregroundColor(Color.textColor)

                            VStack(spacing: 8) {
                                HStack {
                                    Text("4")
                                        .font(.system(size: 32,weight: .bold))
                                        .foregroundColor(Color.textColor)
                                    Text("位")
                                        .font(.system(size: 24,weight: .bold))
                                        .foregroundColor(Color.textColor)
                                }

                                Rectangle()
                                    .fill(NoticeGradation.gradient(baseColor: Color(hex: "#F1BC00")))
                                    .frame(height: 3)
                            }
                        }
                        VStack(spacing: 8) {
                            Text("合計獲得ポイント")
                                .font(.system(size: 14,weight: .light))
                                .foregroundColor(Color.textColor)

                            HStack(spacing: 0) {
                                Text("100000")
                                    .font(.system(size: 20,weight: .bold))
                                    .foregroundColor(Color.textColor)
                                Text("pt")
                                    .font(.system(size: 20,weight: .bold))
                                    .foregroundColor(Color.textColor)
                            }
                        }

                        Spacer()

                        VStack(spacing: 8) {
                            Text("報酬")
                                .font(.system(size: 14,weight: .light))
                                .foregroundColor(Color.textColor)

                            HStack {
                                Image("coin")
                                    .resizable()
                                    .frame(width: 25, height: 25)

                                Text("コイン")
                                    .font(.system(size: 14,weight: .medium))
                                    .foregroundColor(Color.textColor)

                                Spacer()

                                Text("×100")
                                    .font(.system(size: 14,weight: .medium))
                                    .foregroundColor(Color.textColor)
                            }
                            .frame(width: 170)
                            
                            HStack {
                                Image("zettaiman")
                                    .resizable()
                                    .frame(width: 25, height: 25)

                                Text("コイン")
                                    .font(.system(size: 14,weight: .medium))
                                    .foregroundColor(Color.textColor)

                                Spacer()

                                Text("×100")
                                    .font(.system(size: 14,weight: .medium))
                                    .foregroundColor(Color.textColor)
                            }
                            .frame(width: 170)
                        }

                        Spacer()
                    }
                    .frame(width: 270, height: 320, alignment: .center)
                })
                .zIndex(1000)
            }
            
            // ─────────── 「陣取りスタート！」のオーバーレイ ───────────
            if router.didStartFromLoading {
                Text("陣取りスタート！")
                    .font(.system(size: 32,weight: .bold))
                    .foregroundColor(.white)
                    .stroke(color: Color(hex: "#E85B5B"), width: 2)
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
                    gameType: game.type
                )
            }
            .zIndex(1)
        }
        .animation(.easeInOut, value: router.didStartFromLoading)
    }
}

