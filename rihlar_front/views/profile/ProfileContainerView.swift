//
//  ProfileContainerView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/17.
//

import Foundation
import SwiftUI

struct ProfileContainerView: View {
    @ObservedObject var router: Router
    @State private var viewData: UserProfileViewData?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("読み込み中…")
            } else if let viewData = viewData {
                ProfileView(viewData: viewData, router: router)
                    .navigationBarBackButtonHidden(true)
            } else if let errorMessage = errorMessage {
                Text("エラー: \(errorMessage)")
            }
        }
        .task {
            do {
                viewData = try await makeUserProfileViewData()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
