//
//  fetchUserProfile.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/17.
//
import Foundation

func fetchUserProfile() async throws -> User {
    guard let refreshToken = getKeyChain(key: "authToken") else {
        throw NSError(domain: "UserFetch", code: 401, userInfo: [NSLocalizedDescriptionKey: "リフレッシュトークンが見つかりません"])
    }

    print("リフレッシュトークン使用: \(refreshToken)")

    let url = URL(string: "https://rihlar-stage.kokomeow.com/auth/me")!
    print("プロフィール取得URL: \(url.absoluteString)")

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(refreshToken, forHTTPHeaderField: "Authorization") // Bearerなしで

    print("Authorizationヘッダー: \(refreshToken)")

    let (data, response) = try await URLSession.shared.data(for: request)
    print(String(data: data, encoding: .utf8) ?? "No body")

    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        let body = String(data: data, encoding: .utf8) ?? ""
        print("HTTP \(httpResponse.statusCode): \(body)")
        throw NSError(domain: "UserFetch",
                      code: httpResponse.statusCode,
                      userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(body)"])
    }

    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let userInfo = try decoder.decode(User.self, from: data)
    print("取得したユーザー情報: \(userInfo)")

    return userInfo
}
