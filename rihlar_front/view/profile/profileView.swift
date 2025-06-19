//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    //    仮データ
    let images = ["tennpure1", "tennpure2", "tennpure3", "user", "king", "googleIcon"]
    
    var body: some View {
        ZStack{
            Color(Color.backgroundColor)
            
            VStack{
                Spacer().frame(height: 40)
                
                // プロフィール画像
                ZStack{
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 120, height: 120)
                    Image(.user)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                }
                // ユーザーネーム＋編集ボタン
                HStack(alignment:.center, spacing: 10){
                    VStack(spacing: 5){
                        Text("prayer name")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textColor)
                        Rectangle()
                            .frame(width: 180,height: 1)
                            .foregroundColor(.gray)
                    }
                    Button {
                        print("名前変更処理")
                    } label: {
                        Text("編集")
                            .font(.system(size: 14))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .foregroundColor(Color.textColor)
                            .background(Color.buttonColor)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    
                }
                
                // 実績バッジ
                HStack(spacing: 20) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(.king)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(4)
                            )
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.93, blue: 0.87))
                .cornerRadius(20)
                
                // 記録した写真
                Text("記録した写真")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.textColor)
                
                // 写真一覧
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(images.indices, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 160)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 300)
                Spacer()
                
                // ナビゲーションビュー
                HStack{
                    Spacer()
                    VStack{
                        Image
                    }
                }
            }
        }
        
    }
}



#Preview {
    ProfileView()
}
