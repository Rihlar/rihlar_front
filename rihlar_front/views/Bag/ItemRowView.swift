//
//  ItemRowView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/28.
//

import SwiftUI

// アイテム1つを表示する行（アイコン、名前、個数）
struct ItemRowView: View {
    let item: Item // 表示するアイテム
    
    var body: some View {
        
        HStack{
            // アイコン
            Image(item.iconName)
                .foregroundColor(.accentColor)
            // アイテム名
            Text(item.name)
            Spacer()
            // 所持数
            Text("×\(item.count)")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
#Preview {
    ItemRowView(item: Item(id: 1, name: "かまちゃん", count: 3, iconName: "kama"))
}
