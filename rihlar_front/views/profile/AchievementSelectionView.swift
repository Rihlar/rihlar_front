//
//  AchievementSelectionView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI

struct AchievementSelectionView: View {
    // 表示する実績画像の仮データ
    let images = ["king", "king", "king"]
    
    // 表示を閉じるための dismiss 環境変数
    @Environment(\.dismiss) var dismiss
    // 選択せれた画像のインデックスを保持する状態変数
    @State private var selectedImages: Set<Int> = [0,2]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ドラッグインジケーター
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.backgroundColor)
                    .frame(width:80,height: 5)
                    .padding(.top, 12)
                // 緑の区切り線
                Rectangle()
                    .fill(Color.buttonFrameColor)
                    .frame(height: 2)
                    .padding(.top,12)
                
                ScrollView {
                    // 三列のグリットで実績を並べる
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12){
                        
                        // 画像配列のインデックスでループ
                        ForEach(images.indices,id:\.self){
                            index in
                            // 実績画像の背景
                            ZStack(alignment: .topTrailing) {
                                // 丸背景
                                Circle()
                                    .fill(Color.backgroundColor)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(images[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    )
                                    .overlay(
                                        // 点線枠：選択時のみ表示（でも常にレイアウト上は存在）
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(style: StrokeStyle(lineWidth: 4, dash: [5]))
                                            .foregroundColor(Color.buttonFrameColor)
                                            .opacity(selectedImages.contains(index) ? 1 : 0)
                                    )
                                
                                // チェックマーク：選択時のみ
                                if selectedImages.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color.buttonColor)
                                        .background(Circle().fill(Color.white))
                                        .frame(width: 24, height: 24)
                                        .offset(x: -4, y: 4)
                                }
                            }
                            .onTapGesture {
                                if selectedImages.contains(index) {
                                    selectedImages.remove(index)
                                } else {
                                    selectedImages.insert(index)
                                }
                            }
                            
                        }
                    }
                    .padding()
                    
                }
                // スワイプで出したものを閉じる
                Button {
                    dismiss()
                } label: {
                    ShadowedText(
                        "戻る",
                        font: .system(size: 24, weight: .bold),
                        foregroundColor: .white,
                        shadowColor: .black,
                        shadowRadius: 2,
                        offsetY: 0
                    )
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
                }}
            .background(Color.mainDecorationColor)
        }
    }
}
