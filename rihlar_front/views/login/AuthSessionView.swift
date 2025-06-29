//
//  AuthSessionView.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/02.
//



import SwiftUI
import AuthenticationServices

struct AuthSessionView: UIViewControllerRepresentable {
    var callback: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        print("makeUIViewController 呼び出し")
        
        let viewController = UIViewController()
        
        // 少し遅延させてから認証を開始（ViewControllerの準備を待つ）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let success = AuthManager.shared.startAuthentication { callbackURL in
                self.callback(callbackURL)
            }
            
            if !success {
                print("認証開始できませんでした")
            }
        }
        
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {
        // 何もしない
    }
    
    class Coordinator: NSObject {
        // 空のCoordinator - AuthManagerが全て管理
    }
}
