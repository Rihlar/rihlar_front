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
    let onMapRequested: ((Photo) -> Void)? 
    @State private var currentIndex: Int
    @Environment(\.dismiss) var dismiss

    init(photos: [Photo], startIndex: Int, onMapRequested: ((Photo) -> Void)? = nil) {
        self.photos = photos
        self.startIndex = startIndex
        self.onMapRequested = onMapRequested
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        if currentIndex < 0 || currentIndex >= photos.count {
            EmptyView()
        } else {
            let photo = photos[currentIndex]

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
                                if let uiImage = photo.cachedImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                } else if let url = URL(string: photo.url) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
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

                // 下部ボタン群
                VStack {
                    Spacer()
                    HStack(spacing: 40) {
                        // 戻るボタン
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
                            .frame(width: 160, height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.buttonColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.buttonFrameColor, lineWidth: 3)
                                    )
                            )
                        }

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
