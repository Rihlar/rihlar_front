//
//  footer.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/10.
//

import SwiftUI

struct footer: View {
    var onCameraTap: () -> Void
    
    var body: some View {
        VStack(spacing: -20) {
            ZStack {
                Image("cameraIcon")
                    .zIndex(10)
                
                Circle()
                    .fill(Color("footerbg"))
                    .frame(width: 70, height: 70)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 5,
                        x: 0,
                        y: 0
                    )
            }
            
            Text("カメラ")
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: .bold))
                .stroke(color: Color("TextBtnColor"), width: 0.8)
                .zIndex(1)
        }
        .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0))
        .onTapGesture {
            onCameraTap()
        }
        
        Spacer()
        
        VStack(spacing: -20) {
            ZStack {
                Image("menuIcon")
                    .zIndex(10)
                
                Circle()
                    .fill(Color("footerbg"))
                    .frame(width: 70, height: 70)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 5,
                        x: 0,
                        y: 0
                    )
            }
            
            Text("メニュー")
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: .bold))
                .stroke(color: Color("TextBtnColor"), width: 0.8)
                .zIndex(1)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
    }
}

