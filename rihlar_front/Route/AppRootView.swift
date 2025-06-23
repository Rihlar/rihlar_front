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
        if isLoggedIn{
            NavigationStack(path: $router.path) {
                // top画面
//                HomeView(router: router)
//                    .navigationBarTitle(for: Route.self){
//                        route in
//                        switch route{
//                        case .camera:
//                            // カメラ画面の遷移
//                        case .profile:
//                            ProfileView()
//                        case .friend:
//                            // フレンド画面の遷移
//                        case .gacha:
//                            // ガチャ画面の遷移
//                        case .items:
//                            // アイテム画面の遷移
//                        case .record:
//                            // 戦績画面の遷移
//                        case .setting:
//                            // 設定画面の遷移
//                        default:
//                            EmptyView()
//                        }
                    }
            }
        } else {
            LoginView {
                isLoggedIn = true
            }
            
        }
    }
    
}
