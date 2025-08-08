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
            .onChange(of: isLoggedIn) { newValue in
                if newValue {
                    Task {
                        await registerUserProfile()
                    }
                }
            }
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
                                CameraViewController(router: router)
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
                                SoloRankingView(router: router)
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
    private func registerUserProfile() async {
        do {
            guard let token = try await TokenManager.shared.getAccessToken() else {
                print("アクセストークンが取得できませんでした")
                return
            }
            
            let bodyDict: [String: String] = [
                "name": "テスト太郎2",
                "record_id": "記録2",
                "comment": "これはテスト用のコメントです。",
                "region_id": "regionId-c161edb9-6aff-4244-8749-707bff2fa3be",
                "system_game_id": "",
                "admin_game_id": ""
            ]
            
            guard let url = URL(string: "https://rihlar-stage.kokomeow.com/user/profile") else {
                print("URLが不正")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(token, forHTTPHeaderField: "Authorization")
            
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("プロフィール登録API成功")
                } else {
                    print("プロフィール登録APIエラー（無視可）: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("通信エラーまたはBodyエンコード失敗: \(error.localizedDescription)")
        }
    }
}
