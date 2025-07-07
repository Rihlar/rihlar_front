//
//  AchievementSelectionView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI

struct AchievementSelectionView: View {
    
    // ViewModelを状態として保持（画面に紐づく）
    @StateObject private var viewModel = RecordsViewModel()

    // プロフィール側と実績状態を共有するためのBinding
    @Binding var records: [Record]

    // シートを閉じるための環境変数
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ドラッグインジケーター（シートの上部に表示されるバー）
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.backgroundColor)
                    .frame(width: 80, height: 5)
                    .padding(.top, 12)

                // 区切り線
                Rectangle()
                    .fill(Color.buttonFrameColor)
                    .frame(height: 2)
                    .padding(.top, 12)

                // 実績アイコンを表示するグリッド
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        ForEach(records.indices, id: \.self) { index in
                            var record = records[index]

                            ZStack(alignment: .topTrailing) {
                                // 常に透明な背景で固定サイズ確保（ズレ防止）
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 100, height: 100)
                                
                                // 白丸は削除。代わりに画像を直接表示
                                Group {
                                    if let url = URL(string: record.imageUrl), record.imageUrl.contains("http") {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                    } else {
                                        Image(record.imageUrl)
                                            .resizable()
                                    }
                                }
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle()) // 丸く切り取る

                                // 点線の選択枠（選択時のみ表示）
                                if record.isSelected {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 4, dash: [5]))
                                        .foregroundColor(Color.buttonFrameColor)
                                        .frame(width: 100, height: 100)
                                }

                                // チェックマーク
                                if record.isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color.buttonColor)
                                        .background(Circle().fill(Color.white))
                                        .frame(width: 24, height: 24)
                                        .offset(x: -4, y: 4)
                                }
                            }
                            .onTapGesture {
                                // 選択数を数える（最大3つまで）
                                let selectedCount = records.filter { $0.isSelected }.count
                                if record.isSelected {
                                    // 選択解除
                                    records[index].isSelected = false
                                } else if selectedCount < 3 {
                                    // 3つ未満のときだけ選択可能
                                    records[index].isSelected = true
                                }
                            }
                        }
                    }
                    .padding()
                }

                // 閉じるボタン（戻る）
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
                            // ベースのボタンカラー
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.buttonColor)

                            // 左から光が当たっているようなグラデーション
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

                            // 枠線と影
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.buttonFrameColor, lineWidth: 4)
                                .shadow(color: Color.buttonFrameColor.opacity(0.6), radius: 4, x: 2, y: 2)
                        }
                    )
                }
                .padding(.bottom, 20)
            }
            .background(Color.mainDecorationColor)
        }
    }
}
