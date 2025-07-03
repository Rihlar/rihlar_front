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
                        ForEach(FriendRecords.mockFriends, id: \.name) { friend in
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
