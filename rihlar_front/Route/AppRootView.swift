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
    @StateObject private var vm = GameViewModel(service: MockGameService())
    
    var body: some View {
        contentView
    }
    
    @ViewBuilder
    private var contentView: some View  {
        Group {
            if isLoggedIn{
                NavigationStack(path: $router.path) {
                    // top画面
                    TopPage(
                        router: router,
                        vm: vm
                    )
                        .navigationDestination(for: Route.self){
                            route in
                            switch route{
                            case .camera:
//                              　カメラ画面の遷移
                                Camera()
                            case .profile:
                                ProfileView(viewData: mockUserProfile, router: router)
                            case .mode:
                                ModeSelection(router: router)
                            case .teamMatch:
                                TeamMatch(router: router)
                            case .loading:
                                LoadingView(router: router, vm: vm)
//                        case .friend:
                                // フレンド画面の遷移
//                        case .gacha:
                                // ガチャ画面の遷移
//                        case .items:
                                // アイテム画面の遷移
//                        case .record:
                                // 戦績画面の遷移
//                        case .setting:
                                // 設定画面の遷移
                            default:
                                EmptyView()
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
