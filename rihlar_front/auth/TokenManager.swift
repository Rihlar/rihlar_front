//
//  TokenManager.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// Token管理クラス
class TokenManager {
    // shared（シングルトン）を使って、アプリ内で1つだけのインスタンスにする
    static let shared = TokenManager()
    
    // 保存に使うキー
    private let tokenKey = "cachedToken"            // UserDefaultsでのトークン保存キー
    private let tokenTimeKey = "cachedTokenTime"    // トークン保存時間のキー
    
    // 初期化をprivateにして、外から勝手にインスタンス化できないようにする
    private init(){}
    
    
    // アクセストークンを取得する（3分以内ならキャッシュを返す）非同期処理
    func getAccessToken() async throws -> String? {
        // 保存されているトークンと保存時間をUserDefalutsから取り出す
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey),
           let savedTime = UserDefaults.standard.object(forKey: tokenTimeKey) as? Date {
            
            // 今の時刻を取得
            let now = Date()
            
            // 保持されてから何秒経ったかを計算
            let secondsPassed = now.timeIntervalSince(savedTime)
            
            // 180秒(3分)以内ならキャッシュ
            if secondsPassed < 180 {
                print("キャッシュからトークンを返す")
                return savedToken
            }else{
                print("トークンが古いよ；；")
            }
            
        }
        // ないor古い(再取得)
        return nil
        
    }
    
    func fetchAndCacheAccessToken() async throws -> String {
        // KeyChainから認証トークン（Authorizationヘッダに使うもの）を取得
        guard let autoToken = getKeyChain(key: "autoToken") else {
            // 取得できなければエラーを投げる
            throw NSError(domain: "TokenManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorizationトークンがありません"])
        }
        
        // トークン取得用のURLを生成（不正なURLならエラー）
        guard let url = URL(string: "https://authbase-test.kokomeow.com/auth/token") else {
            throw NSError(domain: "TokenManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "URLが不正です"])
        }
        
        // URLRequestを作成し、HTTPメソッドをGETに設定
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // HTTPヘッダーにContent-Typeを設定（APIにJSON形式でリクエストすることを伝える）
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 認証に必要なAuthorizationヘッダーにKeyChainから取得したトークンをセット
        request.setValue(autoToken, forHTTPHeaderField: "Authorization")
        
        // URLSessionを使って非同期にAPIへリクエストを送信
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // APIレスポンスのJSONを受け取るための構造体を定義
        struct TokenResponse: Codable {
            let message: String
            let token: String
        }
        
        // 受け取ったJSONデータをデコードし、tokenを取得
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        let token = response.token
        
        // トークンをUserDefaultsに保存（キーはtokenKeyで管理）
        UserDefaults.standard.set(token, forKey: tokenKey)
        
        // トークンを取得した現在時刻もUserDefaultsに保存（有効期限チェック用）
        UserDefaults.standard.set(Date(), forKey: tokenTimeKey)
        
        // 取得成功をログに表示
        print("新しいトークンを取得しました！")
        
        // 取得したトークンを返す
        return token
    }


}

