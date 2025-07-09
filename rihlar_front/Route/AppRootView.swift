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
                                Camera()
                                // 個別画面も戻るボタン非表示に
                                    .navigationBarBackButtonHidden(true)
                            case .profile:
                                ProfileView(viewData: mockUserProfile, router: router)
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
                                SoloRankingView()
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
