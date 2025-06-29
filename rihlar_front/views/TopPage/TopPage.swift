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
    @ObservedObject var vm: GameViewModel
    
    var body: some View {
        if vm.isLoading {
            ProgressView("読み込み中…")
        } else if let game = vm.game {
            TopPageInProgressView(
                vm: vm,
                router: router,
                game: game
            )
        } else if let err = vm.errorMessage {
            Text("エラー: \(err)")
                .foregroundColor(.red)
        }
        else {
            Text("ゲーム情報がありません")
        }
    }
}


