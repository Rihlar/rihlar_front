//
//  camera.swift
//  rihlar_front
//
//  Created by 小淵颯太 on 2025/06/13.
//

import SwiftUI
import CoreLocation

struct Camera: View {
    @StateObject private var locationManager = CameraLocationManager()
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadMessage: String?
    @State private var imageLocation: CLLocation?

    var body: some View {
        VStack(spacing: 20) {
            // 撮影した画像プレビュー
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        Text("ここに写真が表示されます")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }

            // 位置情報表示
            if let location = imageLocation {
                Text("緯度: \(location.coordinate.latitude), 経度: \(location.coordinate.longitude)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                Text("位置情報がありません")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            Spacer(minLength: 20)

            // カメラ起動ボタン
            Button(action: {
                showCamera = true
            }) {
                Text("カメラを起動")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isUploading)

            // アップロードボタン（画像があれば表示）
            if capturedImage != nil {
                Button(action: uploadPhoto) {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                    } else {
                        Text("サーバへアップロード")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isUploading)
            }

            // アップロード結果メッセージ
            if let message = uploadMessage {
                Text(message)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            ImagePicker(
                didFinishPicking: { image, location in
                    if let img = image {
                        capturedImage = img
                        imageLocation = location
                        uploadMessage = nil
                    }
                },
                currentLocation: locationManager.lastLocation  // ここで現在地を渡す
            )
        }
    }

    private func uploadPhoto() {
        guard let image = capturedImage else { return }
        isUploading = true
        uploadMessage = nil

        // UIImage → JPEG Data
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            uploadMessage = "画像データの変換に失敗しました。"
            isUploading = false
            return
        }

        guard let url = URL(string: "https://example.com/api/upload") else {
            uploadMessage = "アップロード先のURLが不正です。"
            isUploading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // 緯度フィールド
        if let loc = imageLocation {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n")
            body.append("\(loc.coordinate.latitude)\r\n")
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n")
            body.append("\(loc.coordinate.longitude)\r\n")
        }
        // 画像ファイルフィールド
        let fileName = "photo_\(Int(Date().timeIntervalSince1970)).jpg"
        let mimeType = "image/jpeg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(jpegData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false

                if let error = error {
                    uploadMessage = "アップロード中にエラーが発生しました。\n\(error.localizedDescription)"
                    return
                }

                if let httpRes = response as? HTTPURLResponse {
                    if (200...299).contains(httpRes.statusCode) {
                        uploadMessage = "アップロードが完了しました！（ステータスコード: \(httpRes.statusCode)）"
                    } else {
                        uploadMessage = "サーバーエラー：ステータスコード \(httpRes.statusCode)"
                    }
                } else {
                    uploadMessage = "予期せぬレスポンスを受信しました。"
                }
            }
        }.resume()
    }
}

// Data に文字列を追加する拡張
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
