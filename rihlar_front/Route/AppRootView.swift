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
    
    var body: some View {
        contentView
    }
    
    @ViewBuilder
    private var contentView: some View  {
        Group {
            if isLoggedIn{
                NavigationStack(path: $router.path) {
                    // top画面
                    topPage(router: router)
                        .navigationDestination(for: Route.self){
                            route in
                            switch route{
                            case .camera:
//                              　カメラ画面の遷移
                                Camera()
                            case .profile:
                                ProfileView()
                            case .mode:
                                ModeSelection(router: router)
                            case .teamMatch:
                                TeamMatch()
                            case .loading:
                                LoadingView(router: router)
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
                loginDesignView {
                    print("ログイン成功！")
                    isLoggedIn = true
                }
            }
        }
    }
    
}
