//
//  CircularImageView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/19.
//

import SwiftUI

/// 丸い背景と丸くクリップした画像を表示する汎用コンポーネント
struct CircularImage: View {
    let imageName: String   // 表示する画像の名前
    let diameter: CGFloat   // 円の直径
    
    var body: some View {
        ZStack {
            // 背景の円
            Circle()
                .fill(Color.white)
                .frame(width: diameter, height: diameter)
            
            // 画像を丸くクリップして重ねる
            if let url = URL(string: imageName), url.scheme == "http" || url.scheme == "https" {
                // URLの場合はAsyncImageで読み込み
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: diameter, height: diameter)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: diameter, height: diameter)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: diameter, height: diameter)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // URLじゃなければローカル画像として表示
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
            }
        }
    }
}

//　   使用例
//    CircularImageView(
//        imageName: "testImg", //　画像
//        diameter: 70,　// 円の直径
//    )
