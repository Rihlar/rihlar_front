//
//  fetchUserProfile.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/17.
//
import Foundation

func fetchUserProfile() async throws -> User {
    // トークン取得
    let accessToken: String

    if let cached = try await TokenManager.shared.getAccessToken() {
        accessToken = cached
    } else {
        accessToken = try await TokenManager.shared.fetchAndCacheAccessToken()
    }
    let url = APIConfig.stagingBaseURL.appendingPathComponent(APIConfig.userInfoEndpoint)

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)

    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw NSError(domain: "UserFetch",
                      code: httpResponse.statusCode,
                      userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(body)"])
    }

    struct AuthMeResponse: Codable {
        let user_id: String
        let name: String
    }

    let decoded = try JSONDecoder().decode(AuthMeResponse.self, from: data)
    return User(id: decoded.user_id, name: decoded.name)
}
