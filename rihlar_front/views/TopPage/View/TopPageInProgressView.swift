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
//    let game: GameResponse.Game
    //    ゲームが終了しているかのフラグ
    @State private var isGameOverFlag = false
    
    @State private var timeString: String = ""
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject private var hk = StepsHealthKit()
    @State private var photos: [PhotoEntity] = []
    @State private var photoError: String?
    
    // 画面内判定用ヘルパー
    private var isUserOnScreen: Bool {
        guard let user = playerPosition.currentLocation else { return false }
        let center = playerPosition.region.center
        let span   = playerPosition.region.span
        let latOK  = abs(center.latitude  - user.latitude)  <= span.latitudeDelta  / 2
        let lonOK  = abs(center.longitude - user.longitude) <= span.longitudeDelta / 2
        return latOK && lonOK
    }
    
    private var bearingAngle: Double {
      guard let user = playerPosition.currentLocation else { return 0 }
      return playerPosition.region.center.bearing(to: user)
    }
    
    var body: some View {
//        if let game = vm.currentGame {
            ZStack {
                // mapkitを使用した地図表示
                CircleMap(
                    playerPosition: playerPosition,
                    circlesByTeam: vm.circlesByTeam,
                    userStepByTeam: vm.userStepByTeam,
                    game: vm.game,
                    currentGameIsAdmin: vm.currentGameIsAdmin
//                    gameStatus: GameStatus(rawValue: game.statusRaw) ?? .notStarted,
//                    gameType: game.type
                )
                .ignoresSafeArea()
                .onAppear {
                    guard let userID = vm.profile?.user_id,
                          let gameID = vm.currentGameID else {
                        print("ユーザープロフィールまだです")
                        return
                    }
                    vm.fetchCircles(for: gameID, userID: userID)
                    vm.fetchUserStep(for: gameID, userID: userID)
                    vm.bindPlayerPositionUpdates(for: userID, playerPosition: playerPosition)
                    vm.fetchCircles(for: gameID, userID: userID)
                    vm.fetchUserStep(for: gameID, userID: userID)
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
                
                Group {
                  if let userLoc = playerPosition.currentLocation {
                    let center = playerPosition.region.center
                    let angle = center.bearing(to: userLoc)

                    ZStack {
                      GeometryReader { geo in
                          let w = geo.size.width
                          let h = geo.size.height
                          let halfW = w / 2
                          let halfH = h / 2

                          // 北（0°）基準のベアリングをラジアンに
                          let rad = angle * .pi / 180

                          let dx = sin(rad) * halfW
                          let dy = -cos(rad) * halfH

                          let topInset = max(0,  cos(rad)) * 10
                          let bottomInset = max(0, -cos(rad)) * 10
                          let leadingInset = max(0, -sin(rad)) * 10
                          let trailingInset = max(0,  sin(rad)) * 10
                          ZStack {
                              Image("BubblePointer")
                                  .rotationEffect(.degrees(angle + 90))
                                  .position(x: halfW + dx, y: halfH + dy)
                                  .animation(.easeInOut(duration: 0.3), value: angle)
                              Text("戻る")
                                  .foregroundColor(.white)
                                  .font(.system(size: 12, weight: .semibold))
                                  .stroke(color: Color("TextColor"), width: 0.8)
                                  .padding(EdgeInsets(top: topInset, leading: leadingInset, bottom: bottomInset, trailing: trailingInset))
                                  .position(x: halfW + dx, y: halfH + dy)
                                  .animation(.easeInOut(duration: 0.3), value: angle)
                          }
                          .frame(width: 42, height: 30)
                          .onTapGesture {
                              playerPosition.resumeFollow()
                          }
                      }
                      .frame(width: 300, height: 420)
                    }
                    .blur(radius: isShowMenu ? 10 : 0)
                    .animation(.easeInOut, value: isShowMenu)
                  }
                }
                .opacity(isUserOnScreen ? 0 : 1)
                .animation(.default, value: isUserOnScreen)
                
                VStack {
                    Header(
                        vm: vm
//                        game: vm.game
                    )
                    
                    Spacer()
                }
                .blur(radius: isShowMenu ? 10 : 0)
                .animation(.easeInOut, value: isShowMenu)
                
                //            見た目は無いけど、remainingTimeString の変化を監視してフラグを立てる）
                Color.clear
                    .onReceive(timer) { _ in
                        if let endTime = vm.game?.admin.EndTime {
                            let newValue = remainingTimeString(until: endTime)
                            timeString = newValue
                        }
                    }
                    .onChange(of: timeString) { newValue in
                        if let game = vm.game {
                            if newValue == "終了" && game.admin.IsFinished ?? false {
                                isGameOverFlag = true
                            }
                        }
                    }
                
                if isGameOverFlag && !vm.currentGameIsAdmin {
                    ModalView(
                        isModal: $isGameOverFlag,
                        titleLabel: "結果",
                        closeFlag: true,
                        action: {
                            isGameOverFlag = false
//                            vm.endGameLocally()
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
                        vm: vm
//                        game: vm.game,
//                        gameType: game.type
                    )
                }
                .zIndex(1)
            }
            .animation(.easeInOut, value: router.didStartFromLoading)
            .task {
                do {
                    let result = try await fetchPhoto()
                    self.photos = result
                } catch {
                    self.photoError = error.localizedDescription
                    print("photo fetch error:", error)
                }
            }
//        }
    }
}

