//
//  CameraViewController.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/22.
//

import SwiftUI
import UIKit

struct CameraViewController: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

        func makeUIViewController(context: Context) -> CameraAVCapture {
            let vc = CameraAVCapture()
            // 必要ならここでプロパティを渡す
            vc.onCancel = {
                dismiss()
            }
            return vc
        }

        func updateUIViewController(_ uiViewController: CameraAVCapture, context: Context) {
            // （リアルタイム更新が不要なら空のままでOK）
        }

        // モーダルを閉じるボタンなどを CameraViewController 側から呼び出せるように
        class Coordinator {
            var parent: CameraViewController
            init(parent: CameraViewController) { self.parent = parent }
        }
        func makeCoordinator() -> Coordinator { .init(parent: self) }
}
