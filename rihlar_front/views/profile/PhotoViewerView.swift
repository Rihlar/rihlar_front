//
//  PhotoViewerView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI

struct PhotoViewerView: View {
    // 表示する画像のファイル名リスト（Assetにある画像など）
    let images: [String]
    // タップされた時の画像の初期位置
    let startIndex: Int
    // 現在表示中のインデックス（スワイプで変わる）
    @State private var currentIndex: Int
    // 表示を閉じるための dismiss 環境変数
    @Environment(\.dismiss) var dismiss
    // イニシャライザで初期化
    init(images: [String], startIndex: Int) {
        self.images = images
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        if currentIndex >= images.count {
            // インデックスが範囲外なら表示しない
            Color.clear
        } else {
            ZStack{
                // 背景色
                Color.mainDecorationColor.ignoresSafeArea()
                // 横須ワイプで画面切り替えする
                TabView(selection: $currentIndex) {
                    ForEach(images.indices,id: \.self) { index in
                        VStack(spacing: 20){
                            Spacer()
                                .onAppear {
                                    // 表示せれるたびにログ表示
                                    print("画像名: \(images[index])")
                                    if UIImage(named: images[index]) == nil {
                                        print("UIImageとして読み込めてない")
                                    }
                                }
                            // メイン画像の表示
                            Image(images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 400)
                                .background(Color.red)
                                .padding()
                                .background(Color.backgroundColor)
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            // 日付テキスト（画像ごとに仮で違う表示）
                            Text(formattedDate(for: index))
                                .font(.subheadline)
                                .foregroundColor(.textColor)
                            Spacer()
                            
                        }
                        // タブの識別用
                        .tag(index)
                        
                    }
                }
                .tabViewStyle (
                    PageTabViewStyle(indexDisplayMode: .never))
                // 戻るボタン（画面下に固定表示）
                VStack {
                    Spacer()
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
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.buttonColor)
                                
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
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.buttonFrameColor, lineWidth: 4)
                                    .shadow(color: Color.buttonFrameColor.opacity(0.6), radius: 4, x: 2, y: 2)
                            }
                        )
                    }
                    .padding(.bottom, 30)
                    
                }
            }
        }
    }
        // 各インデックスに応じた日付を表示する関数
        func formattedDate(for index: Int) -> String {
            // 仮のフォーマット
            return "2025年5月\(21 + index)日 水曜日　12時30分"
        }
        
    }
    struct PhotoViewerWrapper: View {
        let images: [String]
        let selectedImageIndex: Int?
        
        var body: some View {
            if let index = selectedImageIndex {
                PhotoViewerView(images: images, startIndex: index)
                    .presentationDragIndicator(.hidden)
            } else {
                // 非表示（何も描画しない）
                EmptyView()
            }
        }
    }
    






