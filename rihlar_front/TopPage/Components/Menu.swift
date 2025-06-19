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
                    ProfileMenuItem{
                        print("プロフィールをタップ")
                    }
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
