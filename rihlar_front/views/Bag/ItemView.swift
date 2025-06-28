//
//  ItemView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/27.
//

import SwiftUI

struct ItemView: View {
    var body: some View {
        ZStack{
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                Text("アイテム")
                    
                List{
                    Text("aaaa")
                }
                
            }
        }
    }
}

#Preview {
    ItemView()
}

// アイテムの一個の表示デザイン(アイコン、名前、数)
func ItemList() -> some View {
    Text("アイテム")
}

