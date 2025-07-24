//
//  GachaAnimationState.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

// MARK: - ガチャ演出の状態管理クラス

@MainActor
class GachaAnimationState: ObservableObject {
    @Published var isDimmed = false
    @Published var whiteout = false
    @Published var gachaActive = false
    @Published var characterShown = false
    @Published var whiteCapsuleOffset: CGSize = .zero
    @Published var blueCapsuleOffset: CGSize = .zero
    @Published var undo: CGFloat = 1
    @Published var buttonOpacity: Double = 1.0
    @Published var offset: CGFloat = 75 // カプセル位置Y
    @Published var rotation: Double = 0 // ハンドル回転角度
    @Published var selectedItem: Item? // ガチャで選ばれたアイテム
    
    // アニメ完了時に何かしたいとき用
    var onFinished: (() -> Void)?
    
    // アニメーション開始処理
    func startAnimation(items: [Item]) {
        let randomItem = items.randomElement()
        selectedItem = randomItem
        buttonOpacity = 0.0
        rotation += 720
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // ハンドル回転
            withAnimation { offset = 170 }

            try? await Task.sleep(nanoseconds: 800_000_000) // カプセル出現
            withAnimation { isDimmed = true }

            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation { gachaActive = true }

            try? await Task.sleep(nanoseconds: 500_000_000) // カプセル開封
            withAnimation {
                whiteCapsuleOffset = CGSize(width: -90, height: 90)
                blueCapsuleOffset = CGSize(width: 90, height: 90)
                whiteout = true
            }

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation(.easeInOut(duration: 2.0)) {
                characterShown = true
                undo = 0 // whiteout解除
            }

            try? await Task.sleep(nanoseconds: 2_300_000_000)
            reset()
            onFinished?()
        }
    }
    
    // アニメーション後に状態を初期化
    func reset() {
        isDimmed = false
        whiteout = false
        gachaActive = false
        characterShown = false
        whiteCapsuleOffset = .zero
        blueCapsuleOffset = .zero
        undo = 1
        offset = 75
        rotation = 0
        buttonOpacity = 1.0
        selectedItem = nil
    }
}
