//
//  ProfileViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/08/09.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    /// APIから取得した写真データ
    @Published var photos: [Photo] = []
    /// ローディング中かどうか
    @Published var isLoading = false
    /// エラーメッセージ（nilの場合はエラーなし）
    @Published var errorMessage: String?

    /// 写真リストを読み込み
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        do {
            photos = try await GameImageAPI.shared.fetchImageList()
        } catch {
            errorMessage = "画像リストの取得に失敗しました"
        }
        isLoading = false
    }
}
