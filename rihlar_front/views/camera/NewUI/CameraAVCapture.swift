//
//  CameraAVCapture.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/22.
//

import UIKit
import AVFoundation
import CoreLocation

class CameraAVCapture: UIViewController,
                                 AVCapturePhotoCaptureDelegate,
                                 CLLocationManagerDelegate {
    var onCancel: (() -> Void)?
    var onReturnTop: (() -> Void)?
    var router: Router?
    // — カメラ関連 —
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?

    // — 位置情報管理 —
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    // — ヘルスケア(歩数) —
    private let stepsHK = StepsHealthKit()

    // — グリッド表示フラグ —
    private var isGridVisible = false
    private var gridLayer: CAShapeLayer?

    /// ズーム倍率管理
    private var minZoomFactor: CGFloat = 1.0
    private var maxZoomFactor: CGFloat = 1.0
    private var currentZoomFactor: CGFloat = 1.0

    // — 露出バイアス管理 —
    private var initialExposureBias: Float = 0
    private var minExposureFactor: Float = 0
    private var maxExposureFactor: Float = 0
    private var currentExposureFactor: Float = 0

    // 撮影ボタン
    private lazy var captureButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 32
        b.backgroundColor = .white
        b.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        return b
    }()

    // キャンセルボタン
    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("キャンセル", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return btn
    }()

    // グリッドトグルボタン
    private lazy var gridToggleButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let icon = UIImage(systemName: "square.grid.3x3", withConfiguration: config)
        b.setImage(icon, for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(didTapGridToggle), for: .touchUpInside)
        return b
    }()

    /// 露出バイアスを可視化する縦向きゲージ
    private lazy var exposureGauge: UIProgressView = {
        let g = UIProgressView(progressViewStyle: .bar)
        g.transform = CGAffineTransform(rotationAngle: .pi)
        g.trackTintColor    = UIColor.white.withAlphaComponent(0.3)
        g.progressTintColor = UIColor.systemYellow
        g.translatesAutoresizingMaskIntoConstraints = false
        return g
    }()

    // カメラ切り替えボタン
    private lazy var switchButton: UIButton = {
        let b = UIButton(type: .system)
        let icon = UIImage(systemName: "camera.rotate")
        b.setImage(icon, for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        return b
    }()
    
    private lazy var topBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // カメラの準備
        setupCaptureSession()

        // 位置情報の初期設定
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // 明るさスライド用パンジェスチャー
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleExposurePan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)

        setupPreview()
        setupUI()
        setupZoom()
        startSession()
        setupTapToFocus()

        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    // MARK: — セッション & 入出力設定

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // バックカメラ入力
        guard let backInput = makeDeviceInput(position: .back) else {
            print("バックカメラの入力作成に失敗")
            return
        }
        captureSession.addInput(backInput)
        currentInput = backInput

        // ビデオ出力
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        // 写真出力
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }

    private func makeDeviceInput(position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        guard let device = discovery.devices.first,
              let input = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }
        return input
    }

    // MARK: — プレビュー & UI

    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
//        view.layer.addSublayer(previewLayer)
    }

    private func setupUI() {
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
          // --- Top Bar ---
          topBar.topAnchor.constraint(equalTo: view.topAnchor),
          topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          topBar.heightAnchor.constraint(equalToConstant: 88),  // ステータス＋余裕。調整OK
        ])
        
        view.addSubview(bottomBar)
        NSLayoutConstraint.activate([
          // --- Bottom Bar ---
          bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          bottomBar.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        [cancelButton, captureButton, switchButton, gridToggleButton].forEach {
          bottomBar.addSubview($0)
          $0.translatesAutoresizingMaskIntoConstraints = false
        }
    
        NSLayoutConstraint.activate([
          // 再撮影（キャンセル）ボタン
          cancelButton.bottomAnchor.constraint(equalTo: bottomBar.safeAreaLayoutGuide.bottomAnchor, constant: -12),
          cancelButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
          cancelButton.widthAnchor.constraint(equalToConstant: 120),
          cancelButton.heightAnchor.constraint(equalToConstant: 44),

          // 撮影ボタン
          captureButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
          captureButton.bottomAnchor.constraint(equalTo: bottomBar.safeAreaLayoutGuide.bottomAnchor, constant: -80),
          captureButton.widthAnchor.constraint(equalToConstant: 64),
          captureButton.heightAnchor.constraint(equalToConstant: 64),

          // カメラ切替ボタン
          switchButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
          switchButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 80),
          switchButton.widthAnchor.constraint(equalToConstant: 40),
          switchButton.heightAnchor.constraint(equalToConstant: 40),

          // グリッドトグルボタン
          gridToggleButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
          gridToggleButton.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor, constant: -80),
          gridToggleButton.widthAnchor.constraint(equalToConstant: 40),
          gridToggleButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // MARK: — ズーム & フォーカス設定

    private func setupZoom() {
        guard let device = currentInput?.device else { return }

        // 露出バイアス
        minExposureFactor    = device.minExposureTargetBias
        maxExposureFactor    = device.maxExposureTargetBias
        currentExposureFactor = device.exposureTargetBias

        // ズーム倍率
        minZoomFactor    = device.minAvailableVideoZoomFactor
        maxZoomFactor    = device.maxAvailableVideoZoomFactor
        currentZoomFactor = 1.0

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
    }

    private func setupTapToFocus() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus(_:)))
        view.addGestureRecognizer(tap)
    }

    @objc private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = currentInput?.device else { return }
        var newZoom = currentZoomFactor * pinch.scale
        newZoom = max(minZoomFactor, min(newZoom, maxZoomFactor))
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = newZoom
            device.unlockForConfiguration()
        } catch {
            print("ズーム設定に失敗: \(error)")
        }
        if pinch.state == .ended {
            currentZoomFactor = newZoom
            pinch.scale = 1.0
        }
    }

    @objc private func handleTapToFocus(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        guard let device = currentInput?.device,
              device.isFocusPointOfInterestSupported,
              device.isExposurePointOfInterestSupported else { return }
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose
            device.unlockForConfiguration()
            animateFocusIndicator(at: location)
        } catch {
            print("フォーカス／露出設定に失敗: \(error)")
        }
    }

    private func animateFocusIndicator(at point: CGPoint) {
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.center = point
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.backgroundColor = .clear
        focusView.alpha = 0
        view.addSubview(focusView)

        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                focusView.alpha = 1
                focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                focusView.alpha = 0
            }
        }, completion: { _ in
            focusView.removeFromSuperview()
        })
    }

    // MARK: — ボタンアクション

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
        onCancel?()
    }

    @objc private func didTapCapture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func didTapSwitch() {
        guard let currentInput = currentInput else { return }
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        let newPos: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
        if let newInput = makeDeviceInput(position: newPos),
           captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            self.currentInput = newInput
        } else {
            captureSession.addInput(currentInput)
        }
        captureSession.commitConfiguration()
    }

    @objc private func didTapGridToggle() {
        isGridVisible.toggle()
        if isGridVisible {
            addGridOverlay()
            gridToggleButton.tintColor = .systemYellow
        } else {
            gridLayer?.removeFromSuperlayer()
            gridToggleButton.tintColor = .white
        }
    }

    // MARK: — 露出バイアス操作

    @objc private func handleExposurePan(_ pan: UIPanGestureRecognizer) {
        guard let device = currentInput?.device,
              device.isExposureModeSupported(.continuousAutoExposure) else { return }
        if pan.state == .began {
            initialExposureBias = device.exposureTargetBias
        }
        let translation = pan.translation(in: view)
        let maxBias = device.maxExposureTargetBias
        let minBias = device.minExposureTargetBias
        let delta = Float(-translation.y / 2000) * (maxBias - minBias)
        let newBias = max(minBias, min(maxBias, initialExposureBias + delta))
        do {
            try device.lockForConfiguration()
            device.setExposureTargetBias(newBias, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("露出バイアス設定失敗: \(error)")
        }
        if pan.state == .ended || pan.state == .cancelled {
            pan.setTranslation(.zero, in: view)
        }
        let normalized = (newBias - minExposureFactor) / (maxExposureFactor - minExposureFactor)
        exposureGauge.setProgress(normalized, animated: true)
    }

    @objc private func exposureSliderChanged(_ slider: UISlider) {
        guard let device = currentInput?.device,
              device.isExposureModeSupported(.continuousAutoExposure) else { return }
        let bias = slider.value
        do {
            try device.lockForConfiguration()
            device.setExposureTargetBias(bias, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("露出バイアス設定に失敗: \(error)")
        }
        currentExposureFactor = bias
    }

    // MARK: — ライフサイクル

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let conn = previewLayer.connection, conn.isVideoOrientationSupported {
            conn.videoOrientation = videoOrientation()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        addCaptureButtonRing()
    }

    private func addCaptureButtonRing() {
        captureButton.layer.sublayers?
            .filter { $0.name == "captureRing" }
            .forEach { $0.removeFromSuperlayer() }
        let diameter = max(captureButton.bounds.width, captureButton.bounds.height) + 8
        let rect = CGRect(x: -4, y: -4, width: diameter, height: diameter)
        let ring = CAShapeLayer()
        ring.name = "captureRing"
        ring.path = UIBezierPath(ovalIn: rect).cgPath
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = UIColor.white.cgColor
        ring.lineWidth = 4
        captureButton.layer.insertSublayer(ring, at: 0)
    }

    private func addGridOverlay() {
        gridLayer?.removeFromSuperlayer()
        // グリッドを描く対象の矩形領域を計算
        // topBar の下端〜bottomBar の上端までを囲む矩形
        let yMin = topBar.frame.maxY
        let yMax = bottomBar.frame.minY
        let gridRect = CGRect(
            x: 0,
            y: yMin,
            width: view.bounds.width,
            height: yMax - yMin
        )
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        for i in 1...2 {
            let x = gridRect.origin.x + gridRect.width * CGFloat(i) / 3
            path.move(to: CGPoint(x: x, y: gridRect.origin.y))
            path.addLine(to: CGPoint(x: x, y: gridRect.origin.y + gridRect.height))
        }
        for i in 1...2 {
            let y = gridRect.origin.y + gridRect.height * CGFloat(i) / 3
            path.move(to: CGPoint(x: gridRect.origin.x, y: y))
            path.addLine(to: CGPoint(x: gridRect.origin.x + gridRect.width, y: y))
        }
        layer.path = path.cgPath
        layer.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
        layer.lineWidth = 1
        layer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layer)
        gridLayer = layer
    }

    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func videoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:             return .portrait
        case .landscapeLeft:        return .landscapeRight
        case .landscapeRight:       return .landscapeLeft
        case .portraitUpsideDown:   return .portraitUpsideDown
        default:                    return .portrait
        }
    }

    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // MARK: - AVCapturePhotoCaptureDelegate
    private func croppedToVisiblePreview(image fullImage: UIImage) -> UIImage {
        guard let cg = fullImage.cgImage else { return fullImage }

        // ① カメラ映像が実際に映っているレイヤー内の矩形を計算
        //    topBar と bottomBar を除いた領域
        let topBarHeight    = topBar.frame.maxY
        let bottomBarMinY   = bottomBar.frame.minY
        let visibleHeight   = bottomBarMinY - topBarHeight
        let visibleLayerRect = CGRect(
          x: 0,
          y: topBarHeight,
          width: previewLayer.bounds.width,
          height: visibleHeight
        )

        // ② そのレイヤー座標をメタデータ座標系に変換
        let metadataRect = previewLayer.metadataOutputRectConverted(
          fromLayerRect: visibleLayerRect)

        // ③ フル画像のピクセルサイズ
        let pixelW = CGFloat(cg.width)
        let pixelH = CGFloat(cg.height)

        // ④ 正規化→ピクセル座標に変換
        let cropRect = CGRect(
          x: metadataRect.origin.x * pixelW,
          y: metadataRect.origin.y * pixelH,
          width:  metadataRect.size.width  * pixelW,
          height: metadataRect.size.height * pixelH
        )

        // ⑤ クロップ実行
        guard let croppedCG = cg.cropping(to: cropRect) else {
          return fullImage
        }
        return UIImage(
          cgImage: croppedCG,
          scale: fullImage.scale,
          orientation: fullImage.imageOrientation
        )
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        let steps = stepsHK.steps
        print("現在の歩数: \(steps)")

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        let original = UIImage(data: photo.fileDataRepresentation()!)!
        let finalImage = croppedToVisiblePreview(image: original)


        // CameraAVCapture.swift の photoOutput(_:didFinishProcessingPhoto:) 内
        DispatchQueue.main.async {
            let previewVC = PhotoPreviewViewController(
              captured: finalImage,
              coordinate: self.lastLocation?.coordinate,
              steps: self.stepsHK.steps
            )
            previewVC.onReturnTop = { [weak self] in
                self?.router?.path.removeAll() // TopPageに戻る
            }
            previewVC.modalPresentationStyle = .fullScreen
            self.present(previewVC, animated: true)
        }

    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報取得失敗: \(error)")
    }
}

// MARK: - ビデオデータ出力デリゲート

extension CameraAVCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // フレームごとの処理（例えば画像解析など）
    }
}

extension UIImage {
    /// 中央から targetSize に近い縦横比でクロップした画像を返す
    func cropped(to targetSize: CGSize) -> UIImage? {
        // 元画像のピクセルサイズ
        let imgSize = CGSize(width: self.size.width * self.scale,
                             height: self.size.height * self.scale)
        // 比率計算
        let targetRatio = targetSize.width / targetSize.height
        let imgRatio    = imgSize.width / imgSize.height

        var cropRect = CGRect.zero
        if imgRatio > targetRatio {
            // 元画像が横長 → 横を切り詰める
            let newWidth = imgSize.height * targetRatio
            cropRect.size = CGSize(width: newWidth, height: imgSize.height)
            cropRect.origin = CGPoint(x: (imgSize.width - newWidth) / 2, y: 0)
        } else {
            // 元画像が縦長 → 縦を切り詰める
            let newHeight = imgSize.width / targetRatio
            cropRect.size = CGSize(width: imgSize.width, height: newHeight)
            cropRect.origin = CGPoint(x: 0, y: (imgSize.height - newHeight) / 2)
        }

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}


