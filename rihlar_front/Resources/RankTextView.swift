//
//  RankTextView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/24.
//

import SwiftUI

struct RankTextView: View {
    let text: String
    let rank: Int
    
    var body: some View {
        Text(text)
            .font(.title.bold())
            .overlay(gradientView)       // グラデを重ねて
            .mask(Text(text).font(.title.bold())) // 文字にマスク
    }
    
    private var gradientView: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .goldGradientStart, location: 0.0),
                    .init(color: .goldGradientMiddle, location: 0.5),
                    .init(color: .goldGradientStart, location: 1.0),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .silverGradientStart, location: 0.0),
                    .init(color: .silverGradientMiddle, location: 0.5),
                    .init(color: .silverGradientStart, location: 1.0),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3:
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .bronzeGradientStart, location: 0.0),
                    .init(color: .bronzeGradientMiddle, location: 0.5),
                    .init(color: .bronzeGradientStart, location: 1.0),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [.textColor, .textColor]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

}
