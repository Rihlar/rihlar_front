//
//  PhotoViewerView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI

struct PhotoViewerView: View {
    let photos: [Photo]             // 画像情報モデル
    let startIndex: Int
    @State private var currentIndex: Int
    @Environment(\.dismiss) var dismiss
    
    init(photos: [Photo], startIndex: Int) {
        self.photos = photos
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        if currentIndex < 0 || currentIndex >= photos.count {
            EmptyView()
        } else {
            ZStack {
                Color.mainDecorationColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ドラッグインジケーター
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.backgroundColor)
                        .frame(width: 80, height: 5)
                        .padding(.top, 12)
                    
                    // 緑の区切り線
                    Rectangle()
                        .fill(Color.buttonFrameColor)
                        .frame(height: 2)
                        .padding(.top, 12)
                    
                    Spacer()
                }
                
                TabView(selection: $currentIndex) {
                    ForEach(photos.indices, id: \.self) { index in
                        let photo = photos[index]
                        
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Group {
                                if photo.url.starts(with: "http"),
                                   let url = URL(string: photo.url) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    Image(photo.url)
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                            .frame(maxHeight: 400)
                            .padding()
                            .background(Color.backgroundColor)
                            .cornerRadius(20)
                            .shadow(radius: 4)
                            
                            // テーマ表示（小さく）
                            if let theme = photo.theme {
                                Text("テーマ：\(theme)")
                                    .font(.caption)
                                    .foregroundColor(.textColor)
                            }
                            
                            // 投稿日時
                            Text(formattedDate(from: photo.createdAt))
                                .font(.subheadline)
                                .foregroundColor(.textColor)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 戻るボタン（画面下固定）
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
    
    /// 日時を"yyyy年MM月dd日（E）HH:mm"形式に整形
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日（E）HH:mm"
        return formatter.string(from: date)
    }
}
