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
    @ObservedObject var router: Router

        func makeUIViewController(context: Context) -> CameraAVCapture {
            let vc = CameraAVCapture()
            
            vc.router = router
            // 必要ならここでプロパティを渡す
            vc.onCancel = {
                dismiss()
            }
            vc.onReturnTop = {
                router.path.removeAll()
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
