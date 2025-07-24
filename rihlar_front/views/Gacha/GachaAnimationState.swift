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
    @Published var popupShown = false

    @Published var whiteCapsuleOffset: CGSize = .zero
    @Published var blueCapsuleOffset: CGSize = .zero
    @Published var undo: CGFloat = 1
    @Published var buttonOpacity: Double = 1.0
    @Published var offset: CGFloat = 75
    @Published var rotation: Double = 0
    @Published var selectedItem: Item?

    func startAnimation(items: [Item]) {
        let baseItem = items.randomElement()
        selectedItem = baseItem.map {
            // 個数は1固定で作成
            Item(id: $0.id, name: $0.name, count: 1, iconName: $0.iconName, description: $0.description)
        }

        buttonOpacity = 0.0
        withAnimation(.easeInOut(duration: 0.5)) {
            rotation += 720 // 回転トリガー
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { offset = 170 }

            try? await Task.sleep(nanoseconds: 800_000_000)
            withAnimation { isDimmed = true }

            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation { gachaActive = true }

            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation {
                whiteCapsuleOffset = CGSize(width: -90, height: 90)
                blueCapsuleOffset = CGSize(width: 90, height: 90)
                whiteout = true
            }

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
                characterShown = true
                undo = 0
            }

            try? await Task.sleep(nanoseconds: 800_000_000)
            withAnimation {
                popupShown = true
            }

            // 5秒後に自動でポップアップ非表示＆リセット
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.popupShown = false
                self.reset()
            }
        }
    }

    func reset() {
        isDimmed = false
        whiteout = false
        gachaActive = false
        characterShown = false
        popupShown = false
        whiteCapsuleOffset = .zero
        blueCapsuleOffset = .zero
        undo = 1
        offset = 75
        rotation = 0
        buttonOpacity = 1.0
        selectedItem = nil
    }
}
