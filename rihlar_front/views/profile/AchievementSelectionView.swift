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
            VStack {
                ScrollView {
                    // 三列のグリットで実績を並べる
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12){
                        
                        // 画像配列のインデックスでループ
                        ForEach(images.indices,id:\.self){
                            index in
                            // 実績画像の背景
                            ZStack(alignment: .topTrailing){
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame( height: 100)
                                    .overlay(
                                        // 実際の実績画像
                                        Image(images[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height:100)
                                            .clipped()
                                    )
                                // 選択済みならチェックマークを表示
                                if selectedImages.contains(index){
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.buttonColor)
                                        .background(Circle().fill(Color.mainDecorationColor))
                                        // 少し内側に配置
                                        .offset(x:-6,y:6)
                                }
                            }
                            .onTapGesture{
                                // タップ選択のon/off切り替え
                                if selectedImages.contains(index){
                                    selectedImages.remove(index)
                                }else{
                                    selectedImages.insert(index)
                                }
                            }
                        }
                    }
                    .padding()
                    
                }
                // スワイプで出したものを閉じる
                Button("戻る"){
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.buttonColor)
                .cornerRadius(16)
                .padding()
            }
            // ナビゲーションバーのタイトル設定
            .navigationBarTitle("実績選択", displayMode: .inline)
            .background(Color.mainDecorationColor)
        }
    }
}
