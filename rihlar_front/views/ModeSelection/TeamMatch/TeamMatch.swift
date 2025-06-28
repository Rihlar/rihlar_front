//
//  TeamMatch.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/27.
//

import SwiftUI

struct TeamMatch: View {
    var body: some View {
        VStack {
            Text("チームマッチ")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textColor)
            
            Spacer()
            
            BlueBtn(
                label: "ランダムマッチ",
                width: 250,
                height: 150,
                action: {
                    
                },
                isBigBtn: true
            )
            
            Spacer()
                .frame(height: 50)
            
            BlueBtn(
                label: "ルームマッチ",
                width: 250,
                height: 150,
                action: {
                    
                },
                isBigBtn: true
            )
            
            Spacer()
        }
    }
}
