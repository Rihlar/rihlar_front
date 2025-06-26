//
//  ModeChoiceBtn.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/26.
//

import SwiftUI

struct ModeChoiceBtn: View {
    let isModeFlag: Bool
    let width:CGFloat = 300
    let height:CGFloat = 200
    
    var body: some View {
        ZStack {
            if isModeFlag {
//            一番外側にある線を表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.soloModeLine)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 20)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
//            ボタンの大部分である背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.mainDecorationColor)
                .frame(width: width - 4, height: height - 4)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 20)
                )
//            うっすらと白がかかったような表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: width - 20, height: height - 20)
                .clipShape(
//                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
                )
//                グラデーションを別ファイルで作成
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)
                
///                ボタンの要素
                VStack {
                    Image("soloBtnImg")
                        .shadow(color: Color.black.opacity(0.25), radius: 4)
                    
                    Text("個人戦")
                        .font(.system(size: 32,weight: .bold))
                        .foregroundColor(.white)
                        .stroke(color: Color.textColor, width: 2)
                        .shadow(color: Color.black.opacity(0.25), radius: 4)
                }
            } else {
//            一番外側にある線を表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.mulchModeLine)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 20)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
//            ボタンの大部分である背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.mulchModeColor)
                .frame(width: width - 4, height: height - 4)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 20)
                )
//            うっすらと白がかかったような表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: width - 20, height: height - 20)
                .clipShape(
//                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
                )
//                グラデーションを別ファイルで作成
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)
                
///                ボタンの要素
                VStack {
                    Image("mulchBtnImg")
                        .shadow(color: Color.black.opacity(0.25), radius: 4)
                    
                    Text("チーム戦")
                        .font(.system(size: 32,weight: .bold))
                        .foregroundColor(.white)
                        .stroke(color: Color.textColor, width: 2)
                        .shadow(color: Color.black.opacity(0.25), radius: 4)
                }
            }
        }
    }
}

#Preview {
    ModeChoiceBtn(
        isModeFlag: true
    )
    ModeChoiceBtn(
        isModeFlag: false
    )
}
