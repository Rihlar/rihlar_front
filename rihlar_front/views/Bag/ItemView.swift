//
//  ItemView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/27.
//

import SwiftUI

struct ItemView: View {
    // ViewModelを状態として保持（画面に紐づく）
    @StateObject private var viewModel = ItemViewModel()
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                Text("アイテム")
                    .font(.title)
                    .padding()
                
                // アイテム一覧を表示するList
                List(viewModel.items) { item in
                    ItemRowView(item: item) // カスタムビューで1行ずつ表示
                }
                .listStyle(PlainListStyle()) // 枠線などを省いたシンプルなスタイル
                
            }
        }
    }
}

#Preview {
    ItemView()
}

