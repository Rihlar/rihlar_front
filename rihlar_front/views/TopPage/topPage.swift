//
//  topPage.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/06.
//

import SwiftUI
import CoreLocation

struct topPage: View {
    @ObservedObject var router: Router
    @StateObject private var vm = GameViewModel(service: MockGameService())
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("読み込み中…")
            } else if let game = vm.game {
                // ステータスで振り分け
                switch game.status {
                case .notStarted:
                    TopPageNotStartedView()
                case .inProgress:
                    TopPageInProgressView(router: router)
                case .ended:
                    TopPageEndedView()
                }
            } else if let err = vm.errorMessage {
                Text("エラー: \(err)")
                    .foregroundColor(.red)
            } else {
                Text("ゲーム情報がありません")
            }
        }
        .onAppear {
            vm.fetchGame(by: "テスト用GameID")
        }
    }
}
