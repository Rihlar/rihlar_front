//
//  footer.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/10.
//

import SwiftUI

struct Footer: View {
    @ObservedObject var router: Router
//    メニューボタンと戻るボタンのどちらかを親から受け取る
    let isChangeBtn: Bool
//    カメラアイコンタップ時
    var onCameraTap: () -> Void
//    メニュー／戻るアイコンタップ時
    var onMenuTap: () -> Void
    
    var body: some View {
        HStack {
//            ─── カメラボタン ───
            FooterBtn(
                iconName: "cameraIcon",
                label: "カメラ",
                action: onCameraTap,
                padding: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
            )
            
//            Spacer()
            BlueBtn(
                label: "プレイ",
                width: 160,
                height: 100,
                action: {
                    router.push(.mode)
                },
                isBigBtn: true
            )
            .padding( EdgeInsets(top: -100, leading: 0, bottom: 0, trailing: 0))
            
//            ─── メニュー⇄戻る 切り替えボタン ───
            FooterBtn(
                iconName: isChangeBtn ? "backArrowIcon" : "menuIcon",
                label: isChangeBtn ? "戻る" : "メニュー",
                action: onMenuTap,
                padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40)
            )
        }
    }
}

