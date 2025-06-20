//
//  HomeBtn.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/20.
//

import SwiftUI

struct ReturnBtn: View {
    let label: String           // 下に表示するテキスト
    let action: () -> Void      // タップ時の処理
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.subDecorationColor)
                .frame(width: 160, height: 60)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 16)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.buttonColor)
                .frame(width: 156, height: 56)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 16)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: 145, height: 45)
                .clipShape(
//                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 14)
                )
//                グラデーションを別ファイルで作成
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 14),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)
            
            Text(label)
                .font(.system(size: 16,weight: .bold))
                .foregroundColor(.white)
                .stroke(color: Color.textColor, width: 0.8)
        }
        .onTapGesture {
            action()
        }
    }
}
