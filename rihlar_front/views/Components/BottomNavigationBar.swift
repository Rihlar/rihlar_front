//
//  BottomNavigationBar.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI
// ナビゲーションバー（カメラ、ホーム、メニュー、）
// 他の画面でも再利用可能なコンポーネント

struct BottomNavigationBar: View {
    // ボタンのアクション(親Viewから渡す)
    let onCameraTap: () -> Void
    let onHomeTap: () -> Void
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            
            // カメラボタン
            Button {
                print("カメラが押された")
            } label: {
                VStack(spacing: 0) {
                    ZStack{
                        // ボタンの円背景
                        Circle()
                            .fill(Color.backgroundColor)
                            .frame(width: 80, height: 80)
                            .shadow(radius: 2)
                        // アイコン画像（カメラ）
                        Image("camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .foregroundColor(Color.textColor)
                        
                        
                    }
                    .offset(y:8)
                    // テキスト
                    ShadowedText("カメラ", font: .system(size: 24, weight: .bold), foregroundColor: .white, shadowColor: .black, shadowRadius: 2, offsetY: 0)
                    
                }
            }
            
            // ホームボタン
            BlueBtn(
                label: "ホームに戻る",
                width: 160,
                height: 60,
                action: {
                    print("ホームへ戻る")
                },
                isBigBtn: false
            )
            
            // メニューボタン
            Button {
                print("メニューが押された")
            } label: {
                VStack (spacing:0){
                    
                    ZStack {
                        // ボタンの円背景
                        Circle()
                            .fill(Color.backgroundColor)
                            .frame(width: 80, height: 80)
                            .shadow(radius: 2)
                        // アイコン画像（設定）
                        Image("line.3.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.textColor)
                    }
                    .offset(y:8)
                    // テキスト
                    ShadowedText("メニュー", font: .system(size: 24, weight: .bold), foregroundColor: .white, shadowColor: .black, shadowRadius: 2, offsetY: 0)
                    
                }
            }
        }
    }
}


