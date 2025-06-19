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
            Button {
                print("ホームが押された")
            } label: {
                ShadowedText("ホームに戻る", font: .system(size: 24, weight: .bold), foregroundColor: .white, shadowColor: .black, shadowRadius: 2, offsetY: 0)
                
                
                    .frame(width: 180, height: 80)
                    .background(
                        ZStack {
                            // 内側のボタンカラー（buttonColor）
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.buttonColor)
                            
                            // 左から光が当たるグラデーション
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            // 縁の色（buttonFrameColor）
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.buttonFrameColor, lineWidth: 4)
                                .shadow(color: Color.buttonFrameColor.opacity(0.6), radius: 4, x: 2, y: 2)
                        }
                    )
            }
            .cornerRadius(20)
            .shadow(radius:5)
        
            
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


