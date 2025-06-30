//
//  FriendView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/30.
//

import SwiftUI

struct FriendView: View {
    @ObservedObject var router: Router
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    
    var body: some View {
        ZStack {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack {
                Spacer().frame(height: 0)
                
                OrangeBtn(
                    label: "フレンドを追加",
                    width: 160,
                    height: 60,
                    action: {
                        print("フレンド追加ページへ")
                    },
                    isBigBtn: false
                )
                // メニュー表示オーバーレイ
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
                
                // ボトムナビ
                BottomNavigationBar(
                    router: router,
                    isChangeBtn: isChangeBtn,
                    onCameraTap: {
                        router.push(.camera)
                    },
                    onMenuTap: {
                        isChangeBtn.toggle()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowMenu.toggle()
                        }
                    }
                )
            }
            
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        FriendView(router: Router())
    }
}
