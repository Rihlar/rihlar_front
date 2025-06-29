//
//  Notice.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/28.
//

import SwiftUI

struct Notice: View {
    let label: String
    let graColor: Color
    let height: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(NoticeGradation.gradient(baseColor: graColor))
                .frame(height: height)
            
            Text(label)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textColor)
        }
    }
}

#Preview {
    Notice(
        label: "ゲームが開催されました！\n下のボタンからゲームに参加してください！",
        graColor: Color(hex: "#FEE075"),
        height: 40
    )
    
    Notice(
        label: "ゲームが開始されるまでしばらくお待ちください",
        graColor: Color.buttonColor,
        height: 20
    )
}
