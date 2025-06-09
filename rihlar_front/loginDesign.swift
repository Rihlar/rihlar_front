//
//  loginDesign.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/09.
//

import SwiftUI


// 一つのバブルの定義
struct Bubble: Identifiable {
    let id = UUID()
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let delay: Double
}


// 単体バブルのビュー
struct BubbleView: View {
    @State private var animate = false
    let bubble: Bubble

    var body: some View {
        
        Circle()
            .fill(Color.white.opacity(0.2))
            .frame(width: bubble.size, height: bubble.size)
            .position(x: bubble.x, y: bubble.y)
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.0)
            .animation(
                .easeOut(duration: 2.0)
                    .delay(bubble.delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

struct loginDesignView: View {
    //    グラデーションカラーの定義
    let gradient = Gradient(stops: [.init(color:  Color(red: 254/255, green: 224/255, blue: 117/255),  location: 0.2), .init(color: Color(red: 152/255, green: 186/255, blue: 135/255), location: 0.5)])
    var body: some View {
        ZStack {
            //            グラデーション
            LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
            
            
            
            VStack {
                
                Text("ロゴ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                //                googleボタン
                HStack {
                    Image("googleIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Googleアカウントでログイン")
                        .font(.headline)
                }
                //                ボタンデザイン
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                )
            }
        }
    }}




#Preview {
    loginDesignView()
}
