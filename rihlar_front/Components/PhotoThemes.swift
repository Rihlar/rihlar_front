//
//  PhotoThemes.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/07.
//

import SwiftUI

struct PhotoThemes: View {
    let width: CGFloat = 150
    let height: CGFloat = 50
    
    let theme: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 10)
                )
                .opacity(0.8)
            
            VStack {
                Text("今日の写真テーマ")
                    .font(.system(size: 12,weight: .bold))
                    .foregroundColor(.textColor)
                
                Text("『\(theme)』")
                    .font(.system(size: 12,weight: .bold))
                    .foregroundColor(.textColor)
            }
        }
    }
}

#Preview {
    PhotoThemes(theme: "動物")
}
