//
//  ProfileContainerView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/17.
//

import Foundation
import SwiftUI

// ProfileContainerView.swift
struct ProfileContainerView: View {
    @ObservedObject var router: Router
    @State private var viewData: UserProfileViewData?
    @StateObject private var photoViewModel = ProfileViewModel()
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("読み込み中…")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let viewData = viewData {
                ProfileView(viewData: viewData, router: router)
                    .environmentObject(photoViewModel) // 事前ロード済みデータを渡す
                    .navigationBarBackButtonHidden(true)
            } else if let errorMessage = errorMessage {
                Text("エラー: \(errorMessage)")
            }
        }
        .task {
            do {
                print("プロフィール取得開始")
                viewData = try await makeUserProfileViewData()

                // 写真の先読み
                await photoViewModel.loadPhotos()

                print("プロフィール＋写真取得成功")
            } catch {
                errorMessage = error.localizedDescription
                print("プロフィール取得失敗: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}
