//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    // 仮データ
    let images = ["tennpure1", "tennpure2", "tennpure3", "user", "king", "googleIcon", "googleIcon", "googleIcon", "googleIcon"]
    // タップされた画像のインデックスを管理するState（Optional）
    @State private var selectedImageIndex: ImageIndex? = nil
    
    // 実績を選択する処理をするかどうか
    @State private var showAchievementSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                // プロフィール画像
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 120, height: 120)
                    Image("user")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
                
                // ユーザーネーム＋編集ボタン
                HStack(alignment: .center, spacing: 10) {
                    VStack(spacing: 5) {
                        Text("prayer name")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textColor)
                        Rectangle()
                            .frame(width: 180, height: 1)
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
                Button {
                    showAchievementSheet = true
                } label: {
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
                }
                
                
                // 記録した写真
                Text("記録した写真")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.textColor)
                
                // 写真一覧（下にスペース追加）
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(images.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 160)
                                .overlay(
                                    Image(images[index])
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                )
                                .onTapGesture {
                                    //画像をタップしたら、その画像のインデックスをselectedImageIndexにセットして
                                    //PhotoViewerViewをsheetで表示するトリガーにする
                                    selectedImageIndex = ImageIndex(id: index)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120) // 　ナビゲーションと被らないようにする
                }
            }
            
            // ZStack内で最前面に置くナビゲーション
            BottomNavigationBar(
                onCameraTap: { print("カメラタップ") },
                onHomeTap: { print("ホームタップ") },
                onMenuTap: { print("メニュータップ") }
            )
            .padding(.bottom, 30)
        }
        //selectedImageIndexがセットされたら、対応する画像からPhotoViewerViewをsheet表示
        .sheet(item: $selectedImageIndex) { imageIndex in
            PhotoViewerView(images: images, startIndex: imageIndex.id)
                .presentationDragIndicator(.hidden)
        }
        
        .sheet(isPresented: $showAchievementSheet) {
            AchievementSelectionView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
}
#Preview {
    ProfileView()
}
// ImageIndex構造体はIdentifiableに準拠し、sheetのitemバインディング用に使う
struct ImageIndex: Identifiable {
    let id: Int
}
