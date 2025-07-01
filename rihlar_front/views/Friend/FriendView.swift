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

    // モック実績データ（アセット名は "king" を共通使用）
    let allMockRecords: [Record] = [
        Record(id: 1, title: "100km歩いた", description: "100km達成", imageUrl: "king", isSelected: true),
        Record(id: 2, title: "10000ポイント", description: "ポイント獲得", imageUrl: "king", isSelected: true),
        Record(id: 3, title: "写真100枚", description: "写真を100枚撮影", imageUrl: "king", isSelected: true),
        Record(id: 4, title: "7日連続", description: "連続で記録", imageUrl: "king", isSelected: true),
        Record(id: 5, title: "個人戦5勝", description: "勝利実績", imageUrl: "king", isSelected: true),
        Record(id: 6, title: "チーム戦5勝", description: "チームで勝利", imageUrl: "king", isSelected: true),
        Record(id: 7, title: "アイテム10個", description: "たくさん集めた", imageUrl: "king", isSelected: true)
    ]

    // フレンドデータ（3件ずつ渡す）
    var mockFriends: [FriendData] {
        [
            FriendData(name: "はるるん", imageName: "user", records: Array(allMockRecords[0..<3])),
            FriendData(name: "こだっち", imageName: "user", records: Array(allMockRecords[3..<6])),
            FriendData(name: "りこぴん", imageName: "user", records: Array(allMockRecords[4..<7]))
        ]
    }

    var body: some View {
        ZStack (alignment: .bottom){
            Color(Color.backgroundColor)
                .ignoresSafeArea(edges: .all)

            VStack(spacing: 16) {
                Spacer().frame(height: 0)

                OrangeBtn(
                    label: "フレンドを追加する",
                    width: 230,
                    height: 70,
                    action: {
                        print("フレンドを追加するページに遷移")
                    },
                    isBigBtn: false
                )

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(mockFriends, id: \.name) { friend in
                            FriendRowView(
                                userName: friend.name,
                                userImageName: friend.imageName,
                                records: friend.records
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                }

                Spacer()
                
            }
            if isShowMenu {
                Color.white.opacity(0.5).ignoresSafeArea()
                Menu(router: router)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            BottomNavigationBar(
                router: router,
                isChangeBtn: isChangeBtn,
                onCameraTap: { router.push(.camera) },
                onMenuTap: {
                    isChangeBtn.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FriendView(router: Router())
}
