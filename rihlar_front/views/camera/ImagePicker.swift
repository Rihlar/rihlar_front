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
    // 写真と位置情報を返すクロージャ
    var didFinishPicking: (UIImage?, CLLocation?) -> Void
    var currentLocation: CLLocation?  // 撮影時の位置情報を受け取る

    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
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
            guard let image = info[.originalImage] as? UIImage else {
                parent.didFinishPicking(nil, nil)
                parent.presentationMode.wrappedValue.dismiss()
                return
            }

            // 撮影時点の位置情報を返す
            parent.didFinishPicking(image, parent.currentLocation)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.didFinishPicking(nil, nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
