//
//  TokenManager.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation


// Token管理クラス
class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "cachedToken"         // UserDefaults保存キー
    private let tokenTimeKey = "cachedTokenTime" // 保存時間
    
    private init() {}
    
    // キャッシュされたトークンを3分以内なら返す
    func getAccessToken() async throws -> String? {
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey),
           let savedTime = UserDefaults.standard.object(forKey: tokenTimeKey) as? Date {
            
            let now = Date()
            let secondsPassed = now.timeIntervalSince(savedTime)
            
            if secondsPassed < 180 {
                print("キャッシュからトークンを返す")
                return savedToken
            } else {
                print("トークンが古いよ；；")
            }
        }
        return nil
    }
    
    // APIからトークンを取得しUserDefaultsに保存
    func fetchAndCacheAccessToken() async throws -> String {
        guard let autoToken = getKeyChain(key: "authToken") else {
            throw NSError(domain: "TokenManager", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Authorizationトークンがありません"])
        }
        print("KeyChainから取得したトークン: [\(autoToken)]")
        
        guard let url = URL(string: "https://authbase-test.kokomeow.com/auth/token") else {
            throw NSError(domain: "TokenManager", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "URLが不正です"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorizationヘッダーに必ず"Bearer "を付ける
        request.setValue(autoToken, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // ステータスコードチェック
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTPステータスコード: \(httpResponse.statusCode)")
            if !(200...299).contains(httpResponse.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "(no body)"
                throw NSError(domain: "TokenManager",
                              code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "HTTPエラー: \(httpResponse.statusCode), body: \(body)"])
            }
        }
        
        if let raw = String(data: data, encoding: .utf8) {
            print("レスポンスの生データ: \(raw)")
        }
        
        struct TokenResponse: Codable {
            let message: String
            let token: String
        }
        
        let responseObj = try JSONDecoder().decode(TokenResponse.self, from: data)
        let token = responseObj.token
        
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(Date(), forKey: tokenTimeKey)
        
        print("新しいトークンを取得しました！")
        
        return token
    }
}
