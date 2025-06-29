//
//  BottomNavigationBar.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/19.
//

import SwiftUI
// ナビゲーションバー（カメラ、ホーム、メニュー、）
// 他の画面でも再利用可能なコンポーネント

struct BottomNavigationBar: View {
    @ObservedObject var router: Router
    let isChangeBtn: Bool
    // ボタンのアクション(親Viewから渡す)
    let onCameraTap: () -> Void
    let onMenuTap: () -> Void

    
    var body: some View {
        HStack(spacing: 20) {
            FooterBtn(
                iconName: "cameraIcon",
                label: "カメラ",
                action: onCameraTap,
                padding: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
            )
            
            BlueBtn(
                label: "ホームに戻る",
                width: 160,
                height: 60,
                action: {
                    router.path.removeAll()
                },
                isBigBtn: false
            )
            
            FooterBtn(
                iconName: isChangeBtn ? "backArrowIcon" : "menuIcon",
                label: isChangeBtn ? "戻る" : "メニュー",
                action: onMenuTap,
                padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40)
            )
        }
    }
}

//　使用例
//    インポート
//    @ObservedObject var router: Router
//    @State private var isChangeBtn = false
//    @State private var isShowMenu = false

//    画面の最前面に表示できるところに
//        if isShowMenu {
//            Color.white.opacity(0.5)
//                .ignoresSafeArea()
//                .transition(.opacity)
//
//            Menu(router: router)
//                .transition(
//                    .move(edge: .trailing)
//                    .combined(with: .opacity)
//                )
//        }
//
//        BottomNavigationBar(
//            router: router,
//            isChangeBtn: isChangeBtn,
//            onCameraTap: {
//                router.push(.camera)
//            },
//            onMenuTap: {
//                ボタンの見た目切り替えは即時（アニメなし）
//                isChangeBtn.toggle()
//
//            　　メニュー本体の表示はアニメーション付き
//                withAnimation(.easeInOut(duration: 0.3)) {
//                    isShowMenu.toggle()
//                }
//            }
//        )


