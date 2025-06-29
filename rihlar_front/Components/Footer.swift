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

    @ObservedObject var vm: GameViewModel
    let game: Game
    var gameType: Int
    
    var body: some View {
        VStack {
            if (game.status == .notStarted && game.startTime >= Date()) || game.status == .ended {
                if gameType == 1 {
                    Notice(
                        label: "ゲームが開始されるまでしばらくお待ちください",
                        graColor: Color.buttonColor,
                        height: 20
                    )
                }
            }
            
            HStack {
                //            ─── カメラボタン ───
                FooterBtn(
                    iconName: "cameraIcon",
                    label: "カメラ",
                    action: onCameraTap,
                    padding: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
                )
                
                if game.status == .notStarted && game.type == 1 && game.startTime <= Date() {
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
                } else {
                    Spacer()
                }
                
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
}

