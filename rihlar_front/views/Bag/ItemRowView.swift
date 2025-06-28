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
            ZStack{
                Circle()
                    .fill(Color.itemBackgroundColor)
                    .frame(width: 70, height: 70)
                Image(item.iconName)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width:60,height: 60)
            }
            
            // アイテム名
            Text(item.name)
                .font(.title3)
                .bold(true)
                .foregroundStyle(Color.textColor)
            Spacer()
            // 所持数
            Text("×\(item.count)")
                .foregroundColor(Color.textColor)
                .padding(.horizontal, 8)
                .font(.headline)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white) 
                )
        
    }
}

// 表示内容
#Preview {
    ItemRowView(item: Item(id: 1, name: "かまちゃん", count: 3, iconName: "kama"))
}
