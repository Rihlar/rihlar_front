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
    // 現在選択中のタブ（初期値は.friends = フレンド）
    @State private var selectedTab: FriendTab = .friends
    
    var body: some View {
        ZStack (alignment: .bottom){
            // 背景色
            Color(Color.backgroundColor)
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 16) {
                Spacer().frame(height: 0)
                
                // フレンド追加ボタン
                OrangeBtn(
                    label: "フレンドを追加する",
                    width: 230,
                    height: 70,
                    action: {
                        print("フレンドを追加するページに遷移")
                    },
                    isBigBtn: false
                )
                
                // タブ（フレンド・申請中・承認）
                HStack(spacing: 0) {
                    ForEach(FriendTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            tabButtonView(for: tab)
                        }
                    }
                }
                .background(Color(UIColor.systemYellow).opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                
                
                
                ScrollView {
                    VStack(spacing: 16) {
                        tabContentView()
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
    
    // 選択中タブに応じたコンテンツを表示
    @ViewBuilder
    private func tabContentView() -> some View {
        switch selectedTab {
        case .friends:
            ForEach(FriendRecords.mockFriends, id: \.name) { friend in
                FriendRowView(
                    userName: friend.name,
                    userImageName: friend.imageName,
                    records: friend.records
                )
                .padding(.horizontal, 16)
            }
            
        case .requesting:
            Text("申請中のユーザーを表示します")
                .foregroundColor(.gray)
                .padding()
            
        case .pending:
            Text("承認待ちのリストを表示します")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    // タブボタンの見た目
    private func tabButtonView(for tab: FriendTab) -> some View {
        Text(tab.rawValue)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(selectedTab == tab ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                selectedTab == tab ? Color.accentColor : Color.clear
            )
    }
}

#Preview {
    FriendView(router: Router())
}

