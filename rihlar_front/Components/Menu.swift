//
//  Menu.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

struct Menu: View {
    @ObservedObject var router: Router
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(spacing: -16) {
                    ProfileMenuItem{
                        router.push(.profile)
                    }
                    .zIndex(10)
                        
                    MenuList(router: router)
                        .zIndex(1)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                
                }
            }
            Spacer()
        }
    }
}
