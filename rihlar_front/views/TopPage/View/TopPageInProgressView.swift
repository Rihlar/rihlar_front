//
//  TopPageInProgressView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import SwiftUI
import CoreLocation
import Combine

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
    
    private func tryStartFetching() {
        // まずログイン状態を確認
        Task {
            do {
                let token = try await TokenManager.shared.getAccessToken()
                if token == nil {
                    print("❌ ログインしていないため、データフェッチをスキップ")
                    return
                }
            } catch {
                print("❌ ログイン状態確認エラー: \(error)")
                return
            }
        }
        
        guard !vm.profile.isEmpty, let gameID = vm.currentGameID else { 
            print("⏳ プロファイルまたはゲームIDが未設定 - プロファイル: '\(vm.profile)', ゲームID: \(vm.currentGameID ?? "nil")")
            return 
        }
        print("🚀 call getTopRanking")
        vm.fetchCircles(for: gameID, userID: vm.profile)
        vm.fetchUserStep(for: gameID, userID: vm.profile)
        vm.getTopRanking(UserID: vm.profile, gameID: gameID)
        vm.bindPlayerPositionUpdates(for: vm.profile, playerPosition: playerPosition)
    }
    
    private func checkLoginAndInitializeVM() {
        Task {
            do {
                let token = try await TokenManager.shared.getAccessToken()
                if token != nil {
                    print("✅ ログイン済み - GameViewModel初期化開始")
                    await MainActor.run {
                        vm.initializeAfterLogin()
                    }
                } else {
                    print("❌ ログインしていません - GameViewModel初期化スキップ")
                }
            } catch {
                print("❌ ログイン状態確認エラー: \(error)")
            }
        }
    }
    
    var body: some View {
//        if let game = vm.currentGame {
            ZStack {
                // デバッグ情報をログに出力
                Color.clear
                    .onAppear {
                        print("🗺️ TopPageInProgressView onAppear")
                        print("  - 位置情報許可状態: \(playerPosition.locationPermissionStatus)")
                        print("  - 位置情報許可フラグ: \(playerPosition.isLocationPermissionGranted)")
                        
                        // 位置情報許可に関係なく、ログイン状態を確認して初期化
                        print("🚀 初期化チェック開始")
                        checkLoginAndInitializeVM()
                    }
                    .onChange(of: playerPosition.isLocationPermissionGranted) { isGranted in
                        print("🔄 位置情報許可フラグ変更: \(isGranted)")
                        if isGranted {
                            // 位置情報許可が得られた時に再度データフェッチを試行
                            tryStartFetching()
                        }
                    }
                    .onChange(of: playerPosition.locationPermissionStatus) { status in
                        print("🔄 位置情報許可状態変更: \(status)")
                    }
                
                // 位置情報許可が得られている場合のみマップを表示
                if playerPosition.isLocationPermissionGranted {
                    if vm.game != nil {
                        // ゲーム情報があればマップを表示
                        CircleMap(
                            playerPosition: playerPosition,
                            circlesByTeam: vm.circlesByTeam,
                            userStepByTeam: vm.userStepByTeam,
                            game: vm.game,
                            currentGameIsAdmin: vm.currentGameIsAdmin,
                            vm: vm
                        )
                        .ignoresSafeArea()
                        .onAppear { 
                            print("🗺️ CircleMap表示開始")
                            tryStartFetching() 
                        }
                        .onChange(of: vm.profile) { _ in tryStartFetching() }
                        .onChange(of: vm.currentGameID) { _ in tryStartFetching() }
                        .onChange(of: vm.userStepByTeam) { steps in
                            let apiCoords = steps.map { CLLocationCoordinate2D(
                                latitude: $0.latitude,
                                longitude: $0.longitude
                            ) }
                            playerPosition.seedTrack(with: apiCoords)
                        }
                        .blur(radius: isShowMenu ? 10 : 0)
                        .animation(.easeInOut, value: isShowMenu)
                    } else {
                        // ゲーム情報を読み込み中
                        VStack(spacing: 20) {
                            if vm.isLoadingGame {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("ゲーム情報を読み込み中...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.textColor)
                            } else {
                                Text("ゲーム情報がありません")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.textColor)
                                
                                Button("再読み込み") {
                                    checkLoginAndInitializeVM()
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                    }
                } else {
                    // 位置情報許可待ちの表示
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("位置情報の許可を確認しています...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.textColor)
                        
                        // 詳細なステータス表示
                        VStack(spacing: 8) {
                            Text("現在の状態: \(statusText)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            if playerPosition.locationPermissionStatus == .denied {
                                Text("位置情報の利用が拒否されています。\n設定から位置情報の使用を許可してください。")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
                                Button("設定を開く") {
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    }
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            } else if playerPosition.locationPermissionStatus == .restricted {
                                Text("位置情報の利用が制限されています。")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
                
                // 位置情報許可が得られている場合のみ以下のUI要素を表示
                if playerPosition.isLocationPermissionGranted {
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
                } // 位置情報許可チェック終了
                
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
                            if newValue == "終了" && (game.admin.IsFinished ?? false) {
                                isGameOverFlag = true
                            }
                        }
                    }
                
//                Button("POST") {
//                    guard !vm.profile.isEmpty else {
//                        print("ユーザープロフィールまだです")
//                        return
//                    }
//                    vm.bindPlayerPositionUpdates(for: vm.profile, playerPosition: playerPosition)
//                }
                
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
    
    // ステータステキストのComputed Property
    private var statusText: String {
        switch playerPosition.locationPermissionStatus {
        case .notDetermined: return "未決定"
        case .denied: return "拒否"
        case .restricted: return "制限"
        case .authorizedWhenInUse: return "使用中のみ許可"
        case .authorizedAlways: return "常に許可"
        @unknown default: return "不明"
        }
    }
}


