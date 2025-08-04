//
//  UploadResponse.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/08/04.
//


import UIKit
import Foundation

// MARK: - レスポンスモデル
struct UploadResponse: Codable {
    let data: String
    let circleId: String
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case circleId = "circle_id"
    }
}

// MARK: - エラー定義
enum UploadError: Error, LocalizedError {
    case invalidURL
    case imageConversionFailed
    case invalidResponse
    case serverError(Int)
    case noData
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .imageConversionFailed:
            return "画像の変換に失敗しました"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        case .noData:
            return "データがありません"
        case .decodingFailed(let error):
            return "デコードに失敗しました: \(error.localizedDescription)"
        }
    }
}

// MARK: - 画像アップロード関数
func uploadCircleImage(
    accessToken: String,
    circleId: String,
    image: UIImage,
    completion: @escaping (Result<UploadResponse, Error>) -> Void
) {
    
    // URLの設定
    guard let url = URL(string: "https://rihlar-stage.kokomeow.com/game/circle/image/upload") else {
        completion(.failure(UploadError.invalidURL))
        return
    }
    
    // リクエストの作成
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // boundary文字列の生成
    let boundary = "boundary\(UUID().uuidString)"
    
    // ヘッダーの設定
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue(circleId, forHTTPHeaderField: "CircleID")
    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
    
    // 画像をPNGデータに変換
    guard let imageData = image.pngData() else {
        completion(.failure(UploadError.imageConversionFailed))
        return
    }
    
    // マルチパートボディの作成
    var body = Data()
    
    // 開始境界
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    
    // Content-Disposition
    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
    
    // Content-Type
    body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    
    // 画像データ
    body.append(imageData)
    
    // 改行
    body.append("\r\n".data(using: .utf8)!)
    
    // 終了境界
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = body
    
    // リクエストの実行
    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(UploadError.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(UploadError.noData))
                return
            }
            
            do {
                let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                completion(.success(uploadResponse))
            } catch {
                completion(.failure(UploadError.decodingFailed(error)))
            }
        }
    }.resume()
}

// MARK: - 使用例
/*
uploadCircleImage(
    accessToken: "your_access_token_here",
    circleId: "circle-fffe81ae-43eb-4fd7-a01c-8e3c08883314",
    image: yourUIImage
) { result in
    switch result {
    case .success(let response):
        print("アップロード成功:")
        print("Data: \(response.data)")
        print("Circle ID: \(response.circleId)")
        
    case .failure(let error):
        print("アップロード失敗: \(error.localizedDescription)")
    }
}
*/