//
//  ImagePicker.swift
//  rihlar_front
//
//  Created by 小淵颯太 on 2025/06/13.
//

import SwiftUI
import UIKit
import CoreLocation

struct ImagePicker: UIViewControllerRepresentable {
    /// 写真と位置情報を返すクロージャ
    var didFinishPicking: (UIImage?, CLLocation?) -> Void

    /// キャンセルされたときに呼ばれるクロージャ
    var didCancel: () -> Void

    var currentLocation: CLLocation?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        picker.view.backgroundColor = .red
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.didFinishPicking(image, parent.currentLocation)
            } else {
                parent.didFinishPicking(nil, nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.didCancel()
        }
    }
}
