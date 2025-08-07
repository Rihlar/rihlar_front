//
//  TopPageNotStartedView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import SwiftUI

struct TopPageNotStartedView: View {
    @ObservedObject var vm: GameViewModel
    
    var body: some View {
        Text("🕹️ ゲーム開始前です")
            .font(.title).bold()

        Button("ゲームを開始する") {
//            vm.startGameLocally()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
