//
//  header.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/10.
//

import SwiftUI

struct header: View {
    @State private var gameFlag: String = "solo"
    
    var body: some View {
        if gameFlag == "solo" || gameFlag == "mulch" {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .stroke(color: Color("collection"), width: 2)
                    
                    VStack(spacing: -8) {
                        Text("コレクション")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("モード")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .opacity(0)
                
                Image("matchHeader")
                    .overlay(Text("対戦モード")
                        .foregroundColor(Color("TextBtnColor"))
                        .font(.system(size: 16, weight: .bold))
                    )
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .stroke(color: Color("collection"), width: 2)
                    
                    Image("collectionIcon")
                    
                    VStack(spacing: -8) {
                        Text("コレクション")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("モード")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .onTapGesture {
                    gameFlag = "so"
                }
            }
        } else {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .stroke(color: Color("collection"), width: 2)
                    
                    VStack(spacing: -8) {
                        Text("対戦")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("モード")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .opacity(0)
                
                Image("collectionHeader")
                    .overlay(Text("コレクションモード")
                        .foregroundColor(Color("TextBtnColor"))
                        .font(.system(size: 16, weight: .bold))
                    )
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .stroke(color: Color("match"), width: 2)
                    
                    Image("matchIcon")
                    
                    VStack(spacing: -8) {
                        Text("対戦")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("モード")
                            .stroke(color: Color.white, width: 1.4)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .onTapGesture {
                    gameFlag = "solo"
                }
            }
        }
    }
}
