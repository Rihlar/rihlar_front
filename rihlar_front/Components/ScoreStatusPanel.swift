//
//  ScoreStatusPanel.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/26.
//

import SwiftUI

struct ScoreStatusPanel: View {
    let width:CGFloat = 140
    let height:CGFloat = 66
    
    // 動的なデータ
    var rank: Int
    var currentScore: Int
    var scoreToTop: Int
    
    var body: some View {
        ZStack {
//            一番外側にある線を表現
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.separatorLine)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 10)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
//            ボタンの大部分である背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.backgroundColor)
                .frame(width: width - 4, height: height - 4)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 10)
                )
            
            VStack {
                HStack {
                    Text("現在")
                        .font(.system(size: 10,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("\(rank)位")
                        .font(.system(size: 14,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("\(currentScore)点")
                        .font(.system(size: 14,weight: .bold))
                        .foregroundColor(.textColor)
                }
                
                HStack {
                    Text("1位まであと")
                        .font(.system(size: 10,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("\(scoreToTop)位")
                        .font(.system(size: 14,weight: .bold))
                        .foregroundColor(.textColor)
                }
            }
        }
    }
}

#Preview {
    ScoreStatusPanel(
        rank: 2,
        currentScore: 1200,
        scoreToTop: 200
    )
}
