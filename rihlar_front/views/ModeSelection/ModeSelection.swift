//
//  ModeSelection.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/27.
//

import SwiftUI

struct ModeSelection: View {
    @ObservedObject var router: Router
    @State private var isModeFlag: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("モード選択")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textColor)
                
                Spacer()
                
                ModeChoiceBtn(
                    isModeFlag: true,
                    action: {
                        isModeFlag = true
                    }
                )
                
                Spacer()
                    .frame(height: 50)
                
                ModeChoiceBtn(
                    isModeFlag: false,
                    action: {
                        router.push(.teamMatch)
                    }
                )
                
                Spacer()
            }
            
            ModalView(
                isModal: isModeFlag,
                titleLabel: "確認"
            ) {
                VStack(spacing: 30) {
                    Text("本当に個人戦をはじめますか？")
                        .font(.system(size: 16,weight: .bold))
                        .foregroundColor(Color.textColor)
                    
                    HStack {
                        Button(action: {
                            isModeFlag = false
                        }) {
                            Text("戻る")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.redColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            router.push(.loading)
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
    }
}
