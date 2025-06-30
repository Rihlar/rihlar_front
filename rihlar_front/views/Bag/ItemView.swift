//
//  ItemView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/27.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var router: Router
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    // ViewModelを状態として保持（画面に紐づく）
    @StateObject private var viewModel = ItemViewModel()
    // 選ばれたアイテム
    @State private var selectedItem: Item? = nil
    // ポップアップの状態管理
    @State private var showPopup = false
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                Text("アイテム")
                    .font(.title2)
                    .foregroundStyle(Color.textColor)
                // back表示を消す
                    .navigationBarBackButtonHidden(true)
                
                
                // アイテム一覧を表示するList
                List(viewModel.items) { item in
                    Button {
                        selectedItem = item
                        showPopup = true
                    } label: {
                        ItemRowView(item: item)             // カスタムビューで1行ずつ表示
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowSeparator(.hidden)      // 区切り線を消す
                    .listRowBackground(Color.clear) // デフォ背景を消す
                    .padding(.vertical, 4)          // 行間を少し空ける
                    
                    
                    
                }
                .listStyle(PlainListStyle()) // 枠線などを省いたシンプルなスタイル
                
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
                        //   ボタンの見た目切り替えは即時（アニメなし）
                        isChangeBtn.toggle()
                        
                        //　　メニュー本体の表示はアニメーション付き
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowMenu.toggle()
                        }
                    }
                )
                
            }
            .padding(.horizontal)
            // ポップアップ表示
            if let item = selectedItem, showPopup {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showPopup = false
                        }
                    
                    ItemDetailPopup(item: item, isPresented: $showPopup)
                        .transition(.scale)
                        .animation(.easeInOut, value: showPopup)
                        .zIndex(1)
                }
            }
            
            
        }
    }
}

#Preview {
    ItemView(router:Router())
}

