//
//  ProfileViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/08/09.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        do {
            let summaries = try await GameImageAPI.shared.fetchImageList()
            print("📦 取得したサマリー一覧:")
            for summary in summaries {
                print("circleId: \(summary.id), theme: \(summary.theme ?? "なし"), timestamp: \(summary.timestamp)")
            }

            var newPhotos: [Photo] = []

            for summary in summaries {
                do {
                    let detail = try await GameImageAPI.shared.fetchPhotoDetail(circleId: summary.id)
                    print("🔍 詳細情報: \(detail)")

                    let createdAt = ISO8601DateFormatter().date(from: detail.created_at) ?? Date()
                    let photo = Photo(
                        id: detail.image_id,
                        userId: detail.user_id,
                        createdAt: createdAt,
                        theme: detail.theme,
                        shared: detail.shared,
                        gameId: detail.game_id,
                        url: detail.image_url,
                        circleId: summary.id
                    )
                    newPhotos.append(photo)
                } catch {
                    print("⚠️ 詳細取得エラー: \(error.localizedDescription) - circleId: \(summary.id)")
                }
            }

            print("✅ 最終的にセットしたPhoto配列の件数: \(newPhotos.count)")
            photos = newPhotos

        } catch {
            errorMessage = "画像リストの取得に失敗しました"
            print("❌ サマリー取得エラー: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
