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
            
            var newPhotos: [Photo] = []

            // 詳細情報を複数APIで取得（for await もしくは async let で並列化可能）
            for summary in summaries {
                do {
                    let detail = try await GameImageAPI.shared.fetchPhotoDetail(circleId: summary.id)
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
                    // 詳細取得失敗しても他は続ける（必要に応じてログなど）
                }
            }

            photos = newPhotos

        } catch {
            errorMessage = "画像リストの取得に失敗しました"
        }
        isLoading = false
    }
}
