//
//  ModalView.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/27.
//

import SwiftUI

struct ModalView<Content: View>: View {
    let isModal: Bool
    let titleLabel: String
    let content: () -> Content
    
    var body: some View {
        if isModal {
            ZStack {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.mainDecorationColor)
                            .frame(width: 300, height: 50)
                            .clipShape(
                                RoundedCornerShape(corners: [.topLeft, .topRight], radius: 10)
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 5)
                            
                        Text(titleLabel)
                            .font(.system(size: 16,weight: .bold))
                            .foregroundColor(.white)
                    }
                    .zIndex(10)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .frame(width: 300, height: 350)
                            .clipShape(
                                RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: 10)
                            )
                        
                        ScrollView {
                            content()
                                .padding()
                        }
                        .frame(maxWidth: 300, maxHeight: 350)
                    }
                    .zIndex(1)
                }
            }
        }
    }
}

#Preview {
    ModalView(
        isModal: true,
        titleLabel: "結果"
    ) {
        VStack(spacing: 30) {
            Text("本当に個人戦をはじめますか？")
                .font(.system(size: 16,weight: .bold))
                .foregroundColor(Color.textColor)
            
            HStack {
                Button(action: {
                    print("もう一度プレイ")
                }) {
                    Text("戻る")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.redColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    print("もう一度プレイ")
                }) {
                    Text("はじめる")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.subDecorationColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 270, height: 320, alignment: .center)
    }
}
