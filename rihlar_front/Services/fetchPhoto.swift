//
//  fetchPhoto.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/19.
//

import Foundation

func fetchPhoto() async throws -> [PhotoEntity] {
    // アクセストークンをKeychainなどから取得（ここでは authAccessToken として保存されていると仮定）
    guard let accessToken = getKeyChain(key: "authToken") else {
        throw NSError(domain: "PhotoFetch", code: 401, userInfo: [NSLocalizedDescriptionKey: "アクセストークンが見つかりません"])
    }
    
//    print("fetchPhotoアクセストークン使用: \(accessToken)")
    
    // 写真一覧を取得するAPIのエンドポイント
    let path = APIConfig.photo
    let fullURL = APIConfig.stagingBaseURL.appendingPathComponent(path)
    
    print(fullURL)
    
    var request = URLRequest(url: fullURL)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(accessToken, forHTTPHeaderField:"Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        let body = String(data: data, encoding: .utf8) ?? ""
        print("HTTP (httpResponse.statusCode): (body)")
        throw NSError(domain: "PhotoFetch",
                      code: httpResponse.statusCode,
                      userInfo: [NSLocalizedDescriptionKey: "HTTP (httpResponse.statusCode): (body)"])
    }

    let decoder = JSONDecoder()
    let photos = try decoder.decode([PhotoEntity].self, from: data)

    print("取得した写真一覧: (photos)")
    return photos
}
