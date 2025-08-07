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
    var onReturnTop: (() -> Void)?
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
    
    // MARK: - Response Models
    struct CircleIds: Codable {
        let IsAdmin: Bool
        let AdminCircleID: String
        let SystemCircleID: String
    }

    struct CreateCircleResponse: Codable {
        let circleIds: CircleIds
        let result: String
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
        guard let circleURL = URL(string: "https://rihlar-stage.kokomeow.com/gcore/create/circle") else { return }
        
        Task {
          do {
              // アクセストークン取得
              let accessToken = try await TokenManager.shared.getAccessToken()
              
            // サークル作成
            var req = URLRequest(url: circleURL)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(accessToken, forHTTPHeaderField: "Authorization")
              
            do {
              // PayloadをJSON化してセット
              let jsonBody = try JSONSerialization.data(withJSONObject: payload)
              req.httpBody = jsonBody

              // デバッグ用：送信内容確認
              if let bodyString = String(data: jsonBody, encoding: .utf8) {
                  print("▶️ 送信するJSON: \(bodyString)")
              }
              
              // 通信開始
              let (data, resp) = try await URLSession.shared.data(for: req)

              // HTTPレスポンス確認
              guard let http = resp as? HTTPURLResponse else {
                  print("❌ HTTPレスポンスが無効です")
                  return
              }

              print("📡 ステータスコード: \(http.statusCode)")
              
              // ステータスコードが成功（200台）であるか
              guard 200..<300 ~= http.statusCode else {
                  print("❌ サーバーエラー（コード: \(http.statusCode)）")
                  if let responseString = String(data: data, encoding: .utf8) {
                      print("📨 サーバーからのエラーレスポンス: \(responseString)")
                  }
                  return
              }

              // デバッグ用：受信データ確認
              if let responseString = String(data: data, encoding: .utf8) {
                  print("✅ サーバーからのレスポンス: \(responseString)")
              }

              // JSONデコード（型が一致するか確認）
              guard
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
              else {
                  print("❌ JSON解析に失敗しました")
                  return
              }

              // AdminCircleIDの取り出し
              if
                  let circleIds = json["circleIds"] as? [String: Any],
                  let circleID = circleIds["SystemCircleID"] as? String {
                  print("🎉 サークル作成成功！ID: \(circleID)")
                  
                  uploadCircleImage(
                      accessToken: accessToken!,
                      circleId: circleID,
                      image: image
                  ) { result in
                      switch result {
                      case .success(let response):
                          // 成功時の処理
                          print("アップロード成功: \(response.data)")
                          
                      case .failure(let error):
                          // エラー時の処理
                          print("エラー: \(error.localizedDescription)")
                      }
                  }
              } else {
                  print("❌ AdminCircleIDが見つかりませんでした")
              }

            } catch {
              // 通信や変換エラーの捕捉
              print("❌ エラー発生: \(error.localizedDescription)")
            }

            // 5) 完了アラート
            await MainActor.run {
              let alert = UIAlertController(
                title: "保存完了",
                message: "位置・歩数・写真をサーバに保存しました",
                preferredStyle: .alert
              )
              alert.addAction(.init(title: "OK", style: .default) { _ in
                self.dismiss(animated: true) { self.onReturnTop?() }
              })
              self.present(alert, animated: true)
            }

          } catch {
            print("エラー:", error)
          }
        }
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
