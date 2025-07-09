//
//  UserInfo.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/09.
//

import Foundation
// ユーザー情報を取得する関数
func fetchCurrentUser() async throws -> User {
    
    // キャッシュからトークン取得
    var token = try await TokenManager.shared.getAccessToken()
    
    // なければ新規取得
    if token == nil {
        token = try await TokenManager.shared.fetchAndCacheAccessToken()
    }
    // URL
    let url = APIConfig.stageURL.appendingPathComponent(APIConfig.userInfoEndpoint)
    
    // リクエスト設定
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(token,forHTTPHeaderField: "Authorization")
    
    // リクエスト実行
    let (data, _) = try await URLSession.shared.data(for: request)
    // デコード
    let user  = try JSONDecoder().decode(User.self, from: data)
    
    return user
    
}
