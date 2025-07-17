//
//  AuthManager.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//


import SwiftUI
import AuthenticationServices

// 認証状態を管理するシングルトン
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticating = false
    @Published var hasCompletedAuth = false
    
    private var currentSession: ASWebAuthenticationSession?
    private let presentationContext = AuthPresentationContext()
    
    private init() {}
    
    func startAuthentication(callback: @escaping (URL) -> Void) -> Bool {
        print("認証開始チェック - isAuthenticating: \(isAuthenticating), hasCompletedAuth: \(hasCompletedAuth)")
        
        // 既に認証中または完了済みの場合は何もしない
        guard !isAuthenticating && !hasCompletedAuth else {
            print("認証スキップ - 既に実行中または完了済み")
            return false
        }
        
//        let authURL = "https://authbase-test.kokomeow.com/auth/oauth/google?ismobile=1"
        let authURL = "https://rihlar-stage.kokomeow.com/auth/oauth/google?ismobile=1"

        let customURLScheme = "authbase"
        
        guard let url = URL(string: authURL) else {
            print("URL変換失敗")
            return false
        }
        
        // 非同期でState更新を行う
        Task { @MainActor in
            self.isAuthenticating = true
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: customURLScheme) { [weak self] callbackURL, error in
            // 必ずメインスレッドで実行
            Task { @MainActor in
                guard let self = self else { return }
                
                self.isAuthenticating = false
                
                if let callbackURL {
                    print("認証成功: \(callbackURL.absoluteString)")
                    self.hasCompletedAuth = true
                    callback(callbackURL)
                } else if let error {
                    print("認証失敗: \(error.localizedDescription)")
                    // エラーコード2（キャンセル）の場合は特別な処理をしない
                    if (error as NSError).code != 2 {
                        // キャンセル以外のエラーの場合のみログ出力
                        print("予期しないエラー: \(error)")
                    }
                }
                
                self.currentSession = nil
            }
        }
        
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = presentationContext
        
        currentSession = session
        
        // 少し遅延させてから開始（UIの準備を待つ）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            session.start()
            print("認証セッション start() 実行")
        }
        
        return true
    }
    
    func reset() {
        Task { @MainActor in
            hasCompletedAuth = false
            isAuthenticating = false
            currentSession?.cancel()
            currentSession = nil
        }
    }
}

// プレゼンテーションコンテキスト用の独立クラス
class AuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        print("presentationAnchor 呼び出し")
        
        // より安全なwindow取得方法
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
            return window
        }
        
        // フォールバック
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIApplication.shared.windows.first!
    }
}
