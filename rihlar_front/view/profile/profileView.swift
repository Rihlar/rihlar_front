//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    // 仮データ
    let images = ["tennpure1", "tennpure2", "tennpure3", "user", "king", "googleIcon", "googleIcon", "googleIcon", "googleIcon"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                // プロフィール画像
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 120, height: 120)
                    Image("user")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
                
                // ユーザーネーム＋編集ボタン
                HStack(alignment: .center, spacing: 10) {
                    VStack(spacing: 5) {
                        Text("prayer name")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textColor)
                        Rectangle()
                            .frame(width: 180, height: 1)
                            .foregroundColor(.gray)
                    }
                    Button {
                        print("名前変更処理")
                    } label: {
                        Text("編集")
                            .font(.system(size: 14))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .foregroundColor(Color.textColor)
                            .background(Color.buttonColor)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                
                // 実績バッジ
                HStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(.king)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(4)
                            )
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.93, blue: 0.87))
                .cornerRadius(20)
                
                // 記録した写真
                Text("記録した写真")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.textColor)
                
                // 写真一覧（下にスペース追加）
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(images.indices, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 160)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120) // 　ナビゲーションと被らないようにする
                }
            }
            
            // ZStack内で最前面に置くナビゲーション
            HStack(spacing: 20) {

                // カメラ
                Button {
                    print("カメラが押された")
                } label: {
                    VStack(spacing: 0) {
                        ZStack{
                            // 円
                            Circle()
                                .fill(Color.backgroundColor)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 2)
                            // カメラ
                            Image("camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65, height: 65)
                                .foregroundColor(Color.textColor)
                            
                            
                        }
                        .offset(y:8)
                        // テキスト
                        ZStack {
                            // 黒縁を太く（±2までの範囲）
                            ForEach([-2, -1, 0, 1, 2], id: \.self) { x in
                                ForEach([-2, -1, 0, 1, 2], id: \.self) { y in
                                    if x != 0 || y != 0 {
                                        Text("カメラ")
                                            .font(.headline)
                                            .foregroundColor(.textColor)
                                            .offset(x: CGFloat(x), y: CGFloat(y - 6)) // 上に少しずらす
                                    }
                                }
                            }
                            
                            // メインの白文字
                            Text("カメラ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .offset(y: -6)
                        }
                    }
                }

                // ホーム
                Button {
                    print("ホームが押された")
                } label: {
                    ZStack {
                        //                        同じテキストを重ね付けする
                        // 太めの黒縁（8方向＋中心からちょいズラし）
                        ForEach([-2, -1, 0, 1, 2], id: \.self) { x in
                            ForEach([-2, -1, 0, 1, 2], id: \.self) { y in
                                if x != 0 || y != 0 {
                                    Text("ホームに戻る")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                        .offset(x: CGFloat(x), y: CGFloat(y))
                                }
                            }
                        }
                        
                        // 白文字
                        Text("ホームに戻る")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
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
                    .cornerRadius(20)
                    .shadow(radius:5)
                }
                // メニュー
                Button {
                    print("メニューが押された")
                } label: {
                    VStack (spacing:0){
                        
                        ZStack {
                            // 円
                            Circle()
                                .fill(Color.backgroundColor)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 2)
                            // 設定
                            Image("line.3.horizontal")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color.textColor)
                        }
                        .offset(y:8)
                        // ボタン名
                        ZStack {
                            // 黒縁を太く（±2までの範囲）
                            ForEach([-2, -1, 0, 1, 2], id: \.self) { x in
                                ForEach([-2, -1, 0, 1, 2], id: \.self) { y in
                                    if x != 0 || y != 0 {
                                        Text("メニュー")
                                            .font(.headline)
                                            .foregroundColor(.textColor)
                                            .offset(x: CGFloat(x), y: CGFloat(y - 6)) // 上に少しずらす
                                    }
                                }
                            }
                            
                            // メインの白文字
                            Text("メニュー")
                                .font(.headline)
                                .foregroundColor(.white)
                                .offset(y: -6)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    ProfileView()
}
