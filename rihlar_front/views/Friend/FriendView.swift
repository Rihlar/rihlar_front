//
//  FriendView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/30.
//

import SwiftUI

// 上の左右だけ角丸にするカスタムShape
struct TopCornersRoundedShape: Shape {
    var radius: CGFloat = 10
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct FriendView: View {
    @ObservedObject var router: Router
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    // 現在選択中のタブ（初期値は.friends = フレンド）
    @State private var selectedTab: FriendTab = .friends
    
    var body: some View {
        ZStack{
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
                Spacer()
                
                ZStack(alignment: .bottom){
                    VStack(spacing: 0) {
                        // タブ部分
                        HStack(spacing: 0) {
                            ForEach(FriendTab.allCases, id: \.self) { tab in
                                Button {
                                    selectedTab = tab
                                } label: {
                                    tabButtonView(for: tab)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // 下のリスト部分
                        ScrollView {
                            VStack(spacing: 16) {
                                tabContentView()
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                        }
                        .background(Color.mainDecorationColor)
                    }
                    
                    Spacer()
                    
                    
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
            }
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
        let isSelected = selectedTab == tab
        let radius: CGFloat = 20

        return Text(tab.rawValue)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .padding(.vertical, 10)
            .background(
                (isSelected ? Color.mainDecorationColor : Color.subDecorationColor)
                    .clipShape(TopCornersRoundedShape(radius: radius))
            )
    }
}

#Preview {
    FriendView(router: Router())
}

