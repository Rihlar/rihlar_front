//
//  loginView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/09.
//

import SwiftUI

// 一つのバブルの定義
struct Bubble: Identifiable {
    let id = UUID()
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let delay: Double
    let color: Color
}

// 単体バブルのビュー
struct BubbleView: View {
    @State private var animate = false
    
    let bubble: Bubble
    
    var body: some View {
        Circle()
        // 円の中身は透過（透明）
            .fill(Color.clear)
            .frame(width: bubble.size, height: bubble.size)
        // 縁（Stroke）だけをオーバーレイ表示し、縁の不透明度とスケールをアニメーション
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(animate ? 1 : 0), lineWidth: 3) // 白縁3pt
                    .scaleEffect(animate ? 1.0 : 0.5) // スケール変化 小→大
                    .animation(
                        .easeOut(duration: 1.5)
                        .delay(bubble.delay),
                        value: animate
                    )
            )
        // 画面上のランダム位置指定
            .position(x: bubble.x, y: bubble.y)
        // バブル全体のスケールと不透明度もアニメーション
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.8)
            .animation(
                .easeOut(duration: 1.5)
                .delay(bubble.delay),
                value: animate
            )
        // View表示時にアニメーション開始
            .onAppear {
                animate = true
            }
    }
}

// バブルをランダムに背景に表示
struct BackgroundBubblesView: View {
    
    // バブルの色候補（未使用だが保持）
    let colors = [
        Color.red.opacity(0.5),
        Color.blue.opacity(0.5),
        Color.green.opacity(0.5)
    ]
    
    // 12個のバブルをランダム生成
    let bubbles: [Bubble] = (0..<12).map { _ in
        Bubble(
            size: CGFloat.random(in: 50...150),
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
            delay: Double.random(in: 0...2),
            color: [Color.red.opacity(0.5), Color.blue.opacity(0.5), Color.green.opacity(0.5)].randomElement()!
        )
    }
    
    var body: some View {
        ZStack {
            ForEach(bubbles) { bubble in
                BubbleView(bubble: bubble)
            }
        }
    }
}

struct loginDesignView: View {
    @Binding var didReceiveToken: Bool
    @State private var code: String?
    
    // AuthManagerを監視
    @StateObject private var authManager = AuthManager.shared
    
    var onLoginSuccess: () -> Void
    
    let gradient = Gradient(stops: [
        .init(color: Color(red: 254/255, green: 224/255, blue: 117/255), location: 0.2),
        .init(color: Color(red: 152/255, green: 186/255, blue: 135/255), location: 0.5)
    ])
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                BackgroundBubblesView()
                
                VStack {
                    Image("rogo")
                        .resizable()
                        .frame(width: 200,height: 140)
                 
                    Button(action: {
                        startAuthentication()
                    }) {
                        HStack {
                            Image("googleIcon")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text(authManager.isAuthenticating ? "認証中..." : "Googleアカウントでログイン")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 2)
                        )
                    }
                    .disabled(authManager.isAuthenticating || didReceiveToken || authManager.hasCompletedAuth)
                    .opacity((authManager.isAuthenticating || didReceiveToken || authManager.hasCompletedAuth) ? 0.6 : 1.0)
                }
            }
        }
        .onAppear {
            // 画面表示時に認証状態をリセット（必要に応じて）
            if !didReceiveToken {
                authManager.reset()
            }
        }
    }
    
    private func startAuthentication() {
        guard !didReceiveToken && !authManager.hasCompletedAuth && !authManager.isAuthenticating else {
            print("認証中または受信済み。中断")
            return
        }
        
        let success = authManager.startAuthentication { callbackURL in
            handleAuthCallback(callbackURL)
        }
        
        if !success {
            print("認証を開始できませんでした")
        }
    }
    
    private func handleAuthCallback(_ callbackURL: URL) {
        print("AuthCallback 発火")
        
        guard !didReceiveToken else {
//            print("トークン既受信、処理スキップ")
            return
        }
        
        didReceiveToken = true
        
        if let token = getCode(callbackURL: callbackURL) {
//            print("トークン取得成功 → onLoginSuccess()")
            self.code = token
            
            // 非同期処理を実行
            Task{
                do {
                    // まずキャッシュを試す
                    if let token = try await TokenManager.shared.getAccessToken() {
//                        print("キャッシュからトークン取得成功: \(token)")
                        DispatchQueue.main.async {
                            onLoginSuccess()
                        }
                    } else {
                        // キャッシュがなければfetchして取得
                        let token = try await TokenManager.shared.fetchAndCacheAccessToken()
//                        print("新規取得トークン成功: \(token)")
                        DispatchQueue.main.async {
                            onLoginSuccess()
                        }
                    }
                } catch {
                    print("トークン取得失敗: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        didReceiveToken = false
                        authManager.reset()
                    }
                }
            }
            
        } else {
            print("トークン取得失敗")
            DispatchQueue.main.async {
                didReceiveToken = false
                authManager.reset()
            }
        }
    }
}
// 認証結果のURLからトークンを抽出する関数
func getCode(callbackURL: URL) -> String? {
    print(callbackURL)
    
    guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else {
        return nil
    }
    
    if let codeValue = queryItems.first(where: { $0.name == "token" })?.value {
        print("コールバックから取得したトークン: \(codeValue)")
        
        saveKeyChain(tag: "authToken", value: codeValue)
        return codeValue
    } else {
        return nil
    }
}

#Preview {
    loginDesignView(didReceiveToken: .constant(false)) {
        print("プレビュー内ログイン成功コールバック")
    }
}
