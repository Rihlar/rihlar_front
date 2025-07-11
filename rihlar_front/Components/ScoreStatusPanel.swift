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
    var rank: Int
    var currentScore: Int
    
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
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    
                    Text("1位")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("転々")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                    
                    Spacer()
                    
                    Text("10000pt")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                }
                .frame(width: width - 40)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    
                    Text("2位")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("山田太郎")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                    
                    Spacer()
                    
                    Text("5030pt")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                }
                .frame(width: width - 40)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    
                    Text("3位")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("サーモン丼")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                    
                    Spacer()
                    
                    Text("3300pt")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                }
                .frame(width: width - 40)
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color("LineColor").opacity(0.2))
                    .frame(width: 160, height: 1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                    
                    Text("\(rank)位")
                        .font(.system(size: 12,weight: .bold))
                        .foregroundColor(.textColor)
                    
                    Text("自分")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                    
                    Spacer()
                    
                    Text("\(currentScore)pt")
                        .font(.system(size: 10,weight: .medium))
                        .foregroundColor(.textColor)
                }
                .frame(width: width - 40)
            }
        }
    }
}

#Preview {
    ScoreStatusPanel(
        rank: 10,
        currentScore: 0
    )
}
