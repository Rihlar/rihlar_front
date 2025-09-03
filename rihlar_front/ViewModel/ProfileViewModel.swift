//
//  ProfileViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/08/09.
//


import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPhotos() async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. 画像リストを取得
            let summaries = try await GameImageAPI.shared.fetchImageList()

            var newPhotos: [Photo] = []

            for summary in summaries {
                // circleId から URL を生成
                let urlString = "https://rihlar-stage.kokomeow.com/game/circle/image/\(summary.id)"

                let createdAt = Date(timeIntervalSince1970: TimeInterval(summary.timestamp))
                var photo = Photo(
                    id: summary.id,
                    userId: "",          // userId 不要なら空文字
                    createdAt: createdAt,
                    theme: summary.theme,
                    shared: false,       // shared 情報がなければ false
                    gameId: "",          // gameId 不要なら空文字
                    url: urlString,
                    circleId: summary.id,
                    cachedImage: nil
                )
                // UIImageを先にダウンロードしてキャッシュ
                if let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    photo.cachedImage = image
                }
                newPhotos.append(photo)
            }

            // 日付降順にソート
            photos = newPhotos.sorted { $0.createdAt > $1.createdAt }

        } catch {
            errorMessage = "画像リストの取得に失敗しました"
        }

        isLoading = false
    }
}
