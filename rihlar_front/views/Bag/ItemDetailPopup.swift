//
//  ItemDetailPopup.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/28.
//
import SwiftUI


struct ItemDetailPopup: View {
    let item: Item
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // アイテム名
            Text(item.name)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(Color.textColor)
            
            
            // 下線
            Rectangle()
                .frame(width: 200, height: 1)
                .foregroundColor(.gray)
            
            // アイコン
            
            Image(item.iconName)
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .frame(width:90,height: 90)
            
            
            // 所持数
            Text("×\(item.count)")
                .foregroundColor(Color.textColor)
                .padding(.horizontal, 8)
                .font(.headline)
                .fontWeight(.heavy)
            
            // 説明
            Text(item.description.replacingOccurrences(of: " ", with: "\n"))
                .font(.body)
                .multilineTextAlignment(.center)
                .fontWeight(.heavy)
                .padding()
        }
        .frame(width: 280, height: 320)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .padding(40)
    }
}

// ダミーItemとBindingのテスト用
#Preview {
    ItemDetailPopup(
        item: Item(
            id: 1,
            name: "かまちゃん",
            count: 3,
            iconName: "kama",
            description: "お腹がすいた時に食べると幸せになるアイテムです。"
        ),
        isPresented: .constant(true) 
    )
    .background(Color.gray.opacity(0.3)) // ← 背景の雰囲気も再現可能
}
