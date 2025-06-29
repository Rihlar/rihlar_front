//
//  TeamMatch.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/27.
//

import SwiftUI

struct TeamMatch: View {
    @ObservedObject var router: Router
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            
        if isShowMenu {
            Color.white.opacity(0.5)
                .ignoresSafeArea()
                .transition(.opacity)

            Menu(router: router)
                .transition(
                    .move(edge: .trailing)
                    .combined(with: .opacity)
                )
        }

        BottomNavigationBar(
            router: router,
            isChangeBtn: isChangeBtn,
            onCameraTap: {
                router.push(.camera)
            },
            onMenuTap: {
//                ボタンの見た目切り替えは即時（アニメなし）
                isChangeBtn.toggle()

//            　　メニュー本体の表示はアニメーション付き
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowMenu.toggle()
                }
            }
        )
        }
    }
}
