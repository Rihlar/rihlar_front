//
//  TokenManager.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// 保存されたトークン（あれば）と、保存した時間を取り出して、3分以内ならそれを返す処理
class TokenManager {
    // shared（シングルトン）を使って、アプリ内で1つだけのインスタンスにする
    static let shared = TokenManager()
    // 保存に使うキー（UserDefaultsで使うためのラベルみたいなもの）
    private let tokenKey = "cachedToken"
    private let tokenTimeKey = "cachedTokenTime"
    
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
        // トークンがない、または古い時→再取得
        throw NSError(domain: "TokenManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "キャッシュなし、または期限切れ"])
        
    }
    
}

