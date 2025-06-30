//
//  MenuList.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

struct MenuList: View {
    @ObservedObject var router: Router
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color("menuColor"))
                .frame(width: 320, height: 494)
                .clipShape(
//                            角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.bottomLeft], radius: 20)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
            
            VStack(spacing: 0) {
//                       ① フレンド行
                MenuItem(systemName: "person.2", label: "フレンド") {
                    print("フレンドタップ")
                }
                
                MenuItem(systemName: "circle.bottomhalf.filled", label: "ガチャ") {
                    print("circleタップ")
                }
                MenuItem(systemName: "duffle.bag", label: "アイテム") {
                    router.push(.items)
                }
                MenuItem(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90", label: "戦績") {
                    print("clockタップ")
                }

//                        区切り線
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color("LineColor").opacity(0.2))
                    .frame(width: 230, height: 1)

                // 下段アイコン群
                MenuItem(systemName: "questionmark.circle", label: "ゲームのヒント") {
                    print("helpタップ")
                }
                MenuItem(systemName: "envelope", label: "お知らせ") {
                    print("envelopeタップ")
                }
                MenuItem(systemName: "gearshape", label: "設定") {
                    print("settingsタップ")
                }
            }
        }
    }
}
