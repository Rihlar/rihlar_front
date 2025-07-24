//
//  AppRootView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/23.
//

import SwiftUI

// NavigationStackと連携
struct AppRootView: View {
    @StateObject private var router = Router()
    @State private var isLoggedIn = false
    @State private var didReceiveToken = false
    @StateObject private var vm = GameViewModel(service: RealGameService())
    
    var body: some View {
        contentView
    }
    
    @ViewBuilder
    private var contentView: some View  {
        Group {
            if isLoggedIn{
                // ログイン済みの場合はNavigationStackでメイン画面を表示
                NavigationStack(path: $router.path) {
                    TopPage(router: router, vm: vm)
                    // ルート画面は戻るボタンなし（通常はルートには戻るボタンは表示されないが明示的に指定）
                        .navigationBarBackButtonHidden(true)
                    
                    // pathに応じた遷移先画面を定義
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .camera:
//                                Camera()
                                CameraViewController()
                                    .edgesIgnoringSafeArea(.all)
                                // 個別画面も戻るボタン非表示に
                                    .navigationBarBackButtonHidden(true)
                            case .profile:
                                ProfileContainerView(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .gacha:
                                GachaWrapperView(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .mode:
                                ModeSelection(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .teamMatch:
                                TeamMatch(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .loading:
                                LoadingView(router: router, vm: vm)
                                    .navigationBarBackButtonHidden(true)
                            case .friend:
                                FriendView(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .items:
                                ItemView(router: router)
                                    .navigationBarBackButtonHidden(true)
                            case .record:
                                SoloRankingView(router: router,
                                    userId: "userid-50452766-49e8-4dd9-84a1-d02ee1c2425c",
                                                gameId: "gameid-8a5fafff-0b2e-4f2b-b011-da21a5a724cd")
                                    .navigationBarBackButtonHidden(true)
                            default:
                                EmptyView()
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                }
            } else {
                loginDesignView (didReceiveToken: $didReceiveToken){
                    print("ログイン成功！")
                    
                    isLoggedIn = true
                }
            }
        }
    }
    
}
