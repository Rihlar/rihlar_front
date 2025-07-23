//
//  PhotoPreviewViewController.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/22.
//

import UIKit
import CoreLocation
import SwiftUI

class PhotoPreviewViewController: UIViewController, UITextFieldDelegate {
    var onClose: (() -> Void)?
    // MARK: – Properties
    private let image: UIImage
    private let coordinate: CLLocationCoordinate2D?
    private let steps: Int
    private let pholder: String = "動物"

    // MARK: – Initializer
    init(captured: UIImage,
         coordinate: CLLocationCoordinate2D?,
         steps: Int) {
        self.image = captured
        self.coordinate = coordinate
        self.steps = steps
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var themeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = self.pholder
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(Color.backgroundColor)
        setupLayout()
        registerKeyboardNotifications()
        setupDismissKeyboardGesture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: – UI Setup
    private func setupLayout() {
        // 背景ビュー
        let bgView = UIView()
        bgView.backgroundColor = UIColor(Color.CameraPreviewbgColor)
        bgView.layer.cornerRadius = 10
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)

        // キャプチャ画像
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)

        // 緯度・経度ラベル
        let coordLabel = UILabel()
        coordLabel.numberOfLines = 2
        coordLabel.textAlignment = .center
        coordLabel.textColor = UIColor(Color.textColor)
        coordLabel.font = .systemFont(ofSize: 12, weight: .medium)
        coordLabel.translatesAutoresizingMaskIntoConstraints = false
        if let c = coordinate {
            coordLabel.text = String(format: "緯度: %.6f\n経度: %.6f", c.latitude, c.longitude)
        } else {
            coordLabel.text = "位置情報が取得できませんでした"
        }
        view.addSubview(coordLabel)

        // 歩数ラベル
        let stepsLabel = UILabel()
        stepsLabel.textAlignment = .center
        stepsLabel.textColor = UIColor(Color.textColor)
        stepsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.text = "歩数: \(steps)"
        view.addSubview(stepsLabel)

        // テーマ入力ラベル
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor(Color.textColor)
        textLabel.font = .systemFont(ofSize: 18, weight: .bold)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "この写真のテーマは？"
        view.addSubview(textLabel)

        // テーマ入力欄
        view.addSubview(themeTextField)

        // 保存ボタン
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("保存", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor(Color.buttonColor)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        view.addSubview(saveButton)

        // 再撮影ボタン
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("再撮影", for: .normal)
        closeButton.setTitleColor(UIColor(Color.textColor), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(didTapRetake), for: .touchUpInside)
        view.addSubview(closeButton)

        // Auto Layout
        NSLayoutConstraint.activate([
            // 背景ビュー
            bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            bgView.widthAnchor.constraint(equalToConstant: 300),
            bgView.heightAnchor.constraint(equalToConstant: 400),

            // 画像ビュー
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            iv.widthAnchor.constraint(equalToConstant: 280),
            iv.heightAnchor.constraint(equalToConstant: 380),

            // 緯度・経度ラベル
            coordLabel.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 10),
            coordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 歩数ラベル
            stepsLabel.topAnchor.constraint(equalTo: coordLabel.bottomAnchor, constant: 5),
            stepsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // テキスト入力ラベル
            textLabel.bottomAnchor.constraint(equalTo: themeTextField.topAnchor, constant: -10),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // テーマ入力欄
            themeTextField.widthAnchor.constraint(equalToConstant: 300),
            themeTextField.heightAnchor.constraint(equalToConstant: 40),
            themeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeTextField.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -40),

            // 保存ボタン
            saveButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -10),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 44),

            // 再撮影ボタン
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: – Keyboard Handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -kbFrame.height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: – UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: – Actions
    @objc private func didTapSave() {
        let theme = themeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let payload: [String: Any] = [
            "latitude": coordinate?.latitude ?? 0,
            "longitude": coordinate?.longitude ?? 0,
            "steps": steps,
            "theme": theme
        ]
        guard let url = URL(string: "https://rihlar-test.kokomeow.com/gcore/create/circle") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("userid-79541130-3275-4b90-8677-01323045aca5", forHTTPHeaderField: "UserID")

        // ボディ設定
         if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) {
             req.httpBody = jsonData
         }

         // 1) サークル作成API
         URLSession.shared.dataTask(with: req) { data, resp, error in
             guard
                 error == nil,
                 let data = data,
                 let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode,
                 let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                 let ids = json["circleIds"] as? [String], let circleID = ids.first
             else {
                 print("サークル作成失敗", error ?? "")
                 return
             }

             // 2) アクセストークン取得
             guard let accessToken = getKeyChain(key: "authToken") else {
                 print("トークンが取れません")
                 return
             }

             // 3) 画像アップロード
             self.uploadCircleImage(circleID: circleID, image: self.image, accessToken: accessToken) { success in
                 DispatchQueue.main.async {
                     if success {
                         // 4) 完了アラート
                         let alert = UIAlertController(
                             title: "保存完了",
                             message: "位置・歩数・写真をサーバに保存しました",
                             preferredStyle: .alert
                         )
                         alert.addAction(.init(title: "OK", style: .default) { _ in
                             self.dismiss(animated: true) {
                                 self.onClose?()
                             }
                         })
                         self.present(alert, animated: true)
                     } else {
                         // 失敗時のハンドリング
                         let alert = UIAlertController(
                             title: "アップロード失敗",
                             message: "写真のアップロードに失敗しました",
                             preferredStyle: .alert
                         )
                         alert.addAction(.init(title: "OK", style: .default, handler: nil))
                         self.present(alert, animated: true)
                     }
                 }
             }
         }.resume()
    }
    
    // MARK: – 画像アップロード
    /// 完了時に success=true/false を返すクロージャを追加
    func uploadCircleImage(
        circleID: String,
        image: UIImage,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: "https://rihlar-stage.kokomeow.com/game/circle/image/upload") else {
            print("[Debug] URL 生成失敗")
            completion(false); return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        let boundary = "\(UUID().uuidString)"
        req.setValue(circleID, forHTTPHeaderField: "CircleID")
        req.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")

        guard let imageData = image.pngData() else {
            print("[Debug] 画像データ変換失敗")
            completion(false); return
        }

        // body 作成
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        req.setValue("multipart/form-data; boundary=boundary", forHTTPHeaderField: "Content-Type")
        
        if let bodyString = String(data: body, encoding: .utf8) {
            print("[Debug] multipart body:\n\(bodyString)")
        } else {
            // バイナリ部分が混じると UTF-8 に変換できないので、
            // 先頭だけでも見たい場合は prefix で切り出して試す
            let head = body.prefix(200)
            let headString = String(data: head, encoding: .utf8) ?? "<非テキスト部分>"
            print("[Debug] multipart body (head 200 bytes):\n\(headString)")
        }
        
        req.httpBody = body
        
        print("""
             [Debug] --- Upload Request ---
             URL: \(req.url!.absoluteString)
             Method: \(req.httpMethod!)
             Headers: \(req.allHTTPHeaderFields ?? [:])
             Body Size: \(body.count) bytes
             ----------------------------
             """)

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let error = error {
                print("[Debug] ネットワークエラー:", error)
                completion(false)
                return
            }
            // レスポンスステータスを出力
            if let http = resp as? HTTPURLResponse {
                print("[Debug] HTTP Status Code:", http.statusCode)
            } else {
                print("[Debug] レスポンスが HTTPURLResponse ではありません: \(String(describing: resp))")
            }
            // ボディを文字列で出力
            if let data = data, let bodyString = String(data: data, encoding: .utf8) {
                print("[Debug] Response Body:\n\(bodyString)")
            } else {
                print("[Debug] レスポンスボディなし or UTF-8 変換失敗")
            }

            // ステータスコードチェック
            if let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode {
                print("[Debug] 画像アップロード成功")
                completion(true)
            } else {
                print("[Debug] 画像アップロード失敗 statusCode ≠ 2xx")
                completion(false)
            }
        }.resume()
    }

    @objc private func didTapClose() {
        dismiss(animated: true) {
            // CameraThreeViewController 経由でさらに SwiftUI 側を pop
            self.onClose?()
        }
    }
    
    @objc private func didTapRetake() {
        // ここでは純粋にプレビュー画面を閉じるだけ
        dismiss(animated: true, completion: nil)
    }
}
