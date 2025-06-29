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
    
    // エンドポイントから新しいトークンをとってきて保持する関数
    func fetchAndCacheAccessToken() async throws -> String {
        // KeyChainから認証トークンを取得
        guard let autoToken = getKeyChain(key: "autoToken") else{
            throw NSError(domain: "TokenManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorizationトークンがありません"])
        }
        guard let url = URL(string: " https://authbase-test.kokomeow.com/auth/token")else{
            throw NSError(domain: "TokenManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "URLが不正です"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("autoTokeapplication/json", forHTTPHeaderField: "Content-Type")
        request.setValue(autoToken, forHTTPHeaderField: "Authorization")
        
        // 非同期リクエスト
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // サーバーからのjson構造
        struct TokenResponse: Codable {
            let message: String
            let token: String
        }
        // jsonをデコードしてtokenを取得
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        let token = response.token
        
        // トークンと取得時間をUserDefaultsに保存
        UserDefaults.standard.set(token, forKey: "tokenKey")
        UserDefaults.standard.set(Date(), forKey: "tokenTimeKey")
        
        print("新しいトークンを取得しました！")
        
        return token
    }
    
}

