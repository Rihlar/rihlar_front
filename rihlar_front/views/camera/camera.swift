
import SwiftUI
import CoreLocation

struct Camera: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showCamera = true
    @State private var capturedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadMessage: String?
    @State private var imageLocation: CLLocation?
    @State private var testStepCount: Int = 1234
    @State private var theme: String = "動物"
    @Environment(\.dismiss) private var dismiss
    private let stepsHK = StepsHealthKit()

    var body: some View {
        ZStack {
            Color.backgroundColor // 背景色（カスタムカラーを定義しておくこと）
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Spacer()

                // 撮影画像 or プレースホルダー
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .frame(maxWidth: 300)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .frame(maxWidth: 300)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }

                // テーマ表示
                VStack(spacing: 8) {
                    Text("この写真のテーマは？")
                        .font(.body)

                    TextField("", text: $theme)
                        .disabled(true)
                        .frame(height: 44)
                        .frame(maxWidth: 300)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                        .multilineTextAlignment(.center)
                }

                // 保存ボタン
                Button(action: uploadPhoto) {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 120, height: 44)
                            .background(Color.gray)
                            .cornerRadius(20)
                    } else {
                        Text("保存")
                            .foregroundColor(.black)
                            .frame(width: 120, height: 44)
                            .background(Color(red: 0.8, green: 1.0, blue: 1.0))
                            .cornerRadius(20)
                            .shadow(radius: 4)
                    }
                }
                .disabled(capturedImage == nil || isUploading)

                Spacer()
            }

            // アップロード結果
            if let message = uploadMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            if capturedImage == nil {
                showCamera = true
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(
                didFinishPicking: { image, location in
                    if let img = image {
                        capturedImage = img
                        imageLocation = location ?? locationManager.lastLocation
                        uploadMessage = nil
                    }
                },
                didCancel: {
                    // キャンセル時にホームへ戻る
                    dismiss()
                },
                currentLocation: locationManager.lastLocation
            )
        }
    }

    private func uploadPhoto() {
        guard let image = capturedImage else { return }
        isUploading = true
        uploadMessage = nil

        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            uploadMessage = "画像データの変換に失敗しました。"
            isUploading = false
            return
        }

        guard let url = URL(string: "https://rihlar-test.kokomeow.com/gcore/create/circle") else {
            uploadMessage = "アップロード先のURLが不正です。"
            isUploading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("userid-79541130-3275-4b90-8677-01323045aca5", forHTTPHeaderField: "UserID")

        let steps = stepsHK.steps
             print("現在の歩数: \(steps)")
//        var body = Data()
        let body: [String: Any] = [
            "latitude": imageLocation?.coordinate.latitude,
            "longitude": imageLocation?.coordinate.longitude,
            "steps": steps
        ]
        print(body)
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        // 緯度・経度
//        if let loc = imageLocation {
//            print("いど:\(loc.coordinate.latitude)")
//            print("けいど:\(loc.coordinate.longitude)")
//            body.append("--\(boundary)\r\n")
//            body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n")
//            body.append("\(loc.coordinate.latitude)\r\n")
//
//            body.append("--\(boundary)\r\n")
//            body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n")
//            body.append("\(loc.coordinate.longitude)\r\n")
//        }
//
//        // 歩数
//        body.append("--\(boundary)\r\n")
//        body.append("Content-Disposition: form-data; name=\"steps\"\r\n\r\n")
//        body.append("\(testStepCount)\r\n")
        
        

        // 画像データ
//        let fileName = "photo_\(Int(Date().timeIntervalSince1970)).jpg"
//        let mimeType = "image/jpeg"
//        body.append("--\(boundary)\r\n")
//        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(fileName)\"\r\n")
//        body.append("Content-Type: \(mimeType)\r\n\r\n")
//        body.append(jpegData)
//        body.append("\r\n")
//        body.append("--\(boundary)--\r\n")

//        request.httpBody = body

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

                        // ✅ 1秒後に自動的にホームへ戻る
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            dismiss()
                        }
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

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

