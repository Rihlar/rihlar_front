//
//  ScoreStatusPanel.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/26.
//

import SwiftUI

struct ScoreStatusPanel: View {
    let width:CGFloat = 200
    let height:CGFloat = 95
    
    // 動的なデータ
    var topRanking: TopRankingEntity?
    
    private var selfRank: Int {
        topRanking?.data.selfRanking.rank ?? 0
    }
    private var selfPoint: Int {
        topRanking?.data.selfRanking.point ?? 0
    }
    private var top3: [TeamRanking] {
        Array(topRanking?.data.ranks.prefix(3) ?? [])
    }
    
    var body: some View {
        ZStack {
//            ボタンの大部分である背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.backgroundColor)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 10)
                )
                .opacity(0.8)
            
            VStack(spacing: 3) {
                ForEach(Array(top3.enumerated()), id: \.offset) { idx, item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(idx == 0 ? Color.orange : idx == 1 ? Color.red : Color.green)
                            .frame(width: 10, height: 10)

                        Text("\(idx + 1)位")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.textColor)

                        Text(item.userName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.textColor)

                        Spacer()

                        Text("\(item.points)pt")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.textColor)
                    }
                    .frame(width: width - 40)
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color("LineColor").opacity(0.2))
                    .frame(width: 160, height: 1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                    
                    Text("\(selfRank)位")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("自分")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                    
                    Spacer()
                    
                    Text("\(selfPoint)pt")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                }
                .frame(width: width - 40)
            }
        }
    }
}

//#Preview {
//    ScoreStatusPanel(
//        rank: 10,
//        currentScore: 0
//    )
//}
