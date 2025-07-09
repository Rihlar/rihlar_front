//
//  ProfileViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/09.
//

import Foundation

/// Profile画面のデータ取得・保持を担当する ViewModel
/// - 現在はユーザー情報のみAPIから取得し、他のデータ（記録・写真）はモックを使用
@MainActor
class ProfileViewModel: ObservableObject {
    
    /// 画面で表示するためにまとめたデータ（ユーザー・実績・写真）
    @Published var viewData: UserProfileViewData?

    /// ユーザー情報をAPIから取得し、モックのデータと合わせてViewDataに反映する
    func loadProfile() async {
        do {
            // アクセストークン付きでユーザー情報を取得（ステージング用）
            let user = try await fetchCurrentUser()

            // 実績・写真はモックデータ（本番ではAPIから取得予定）
            let records: [Record] = [mockRecord]
            let photos: [Photo] = mockPhotos

            // 画面に渡すデータとしてまとめる
            self.viewData = UserProfileViewData(
                user: user,
                records: records,
                photos: photos
            )
        } catch {
            print("プロフィールの取得に失敗しました: \(error.localizedDescription)")
        }
    }
}
