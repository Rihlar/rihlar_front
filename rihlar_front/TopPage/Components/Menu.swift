//
//  Menu.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

struct Menu: View {
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(spacing: -16) {
//                  ZStack
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color("BtnColor"))
                        .frame(width: 340, height: 90)
                        .clipShape(
    //                        角丸を別ファイルで作成
                            RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 5)
                        .zIndex(10)
                        
                        MenuList()
                            .zIndex(1)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                
                }
            }
            Spacer()
        }
    }
}
