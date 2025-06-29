//
//  TopPage.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/06.
//

import SwiftUI
import CoreLocation

struct TopPage: View {
    @ObservedObject var router: Router
    @StateObject private var vm = GameViewModel(service: MockGameService())
    
    var body: some View {
        if vm.isLoading {
            ProgressView("読み込み中…")
        }
        else if let game = vm.game {
            if game.status == .notStarted {
                TopPageNotStartedView(vm: vm)
            }
            else if game.status == .inProgress {
                TopPageInProgressView(
                    vm: vm,
                    router: router,
                    game: game
                )
            }
            else {  // .ended
                TopPageEndedView()
            }
        }
        else if let err = vm.errorMessage {
            Text("エラー: \(err)")
                .foregroundColor(.red)
        }
        else {
            Text("ゲーム情報がありません")
        }
    }
}


