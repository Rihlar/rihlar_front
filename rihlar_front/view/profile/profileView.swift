//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    //    仮データ
    let images = ["tennpure1", "tennpure2", "tennpure3", "tennpure1", "tennpure2", "tennpure3"]
    var body: some View {
        VStack(spacing: 20){
            Spacer().frame(height: 30)
            
            // アイコン
            // 仮置きとして、googleのアイコンを置いてる本番ならurl
            Image(.googleIcon)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            // ユーザーネーム＋編集ボタン
            HStack{
                // 名前
                Text("prayer name")
                    .fontWeight(.bold)
                    .font(.title3)
                Button {
                    print("名前変更処理")
                } label: {
                    Text("編集")
                }
                
            }
            // 実績バッジ
            HStack(spacing: 20) {
                ForEach(0..<3) { _ in
                    Image(.king)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            // 記録した写真
            Text("記録した写真")
                .font(.title3)
                .foregroundColor(.black)
                .padding(10)
                .background(in: RoundedRectangle(cornerRadius: 10))
                .backgroundStyle(.gray)
                .padding(10)
            
            // ダラーと三列で並べる
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        Spacer().frame(height: 40)
        
    }
}



#Preview {
    ProfileView()
}
