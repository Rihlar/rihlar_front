//
//  NoticeGradation.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/28.
//

import SwiftUI

struct NoticeGradation {
    static func gradient(baseColor: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: baseColor.opacity(0.0), location: 0.0),
                .init(color: baseColor.opacity(1.0), location: 0.5),
                .init(color: baseColor.opacity(0.0), location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

//    Rectangle()
//        .fill(NoticeGradation.gradient(baseColor: 色を入れる))
//        .frame(height: 200)
