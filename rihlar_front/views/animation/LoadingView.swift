//
//  LoadingView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/26.
//

import SwiftUI

// ゲームが始まる前にローディングとして流れるアニメーション

struct LoadingView : View {
    // 流れてるアニメーションの配列で動かすための定義
    @State private var frameindex = 0
    // タイマー
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    // フレーム画像の名前
    let frames = ["loading1","loading2","loading3","loading4"]
    
    var body: some View{
        ZStack{
            // 背景色
            Color.backgroundColor
                .ignoresSafeArea()
            // ローディング画像
            Image(frames[frameindex])
                .resizable()
                .frame(width: 200, height: 150,alignment: .center)
                .onReceive(timer){_ in
                    frameindex = (frameindex + 1) % frames.count
                }
        }
           
    }
       
    
}

#Preview {
    LoadingView()
}
