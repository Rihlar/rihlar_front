//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    // 仮データ
    let images = ["tennpure1", "tennpure2", "tennpure3", "tennpure1", "tennpure2", "tennpure3", "tennpure1", "tennpure2", "tennpure3"]
    @State private var playerName = "Christopherあいうえお山田"
    @State private var isEditing = false
    @FocusState private var isNameFieldFocused: Bool    // フォーカス管理
    
    // タップされた画像のインデックスを管理するState（Optional）
    @State private var selectedImageIndex: ImageIndex? = nil
    // 実績を選択する処理をするかどうか
    @State private var showAchievementSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 0)
                
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
                        HStack{
                            // 入力時と表示時で変化
                            if isEditing{
                                TextField("名前を入力",text: $playerName)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .focused($isNameFieldFocused)
                                    .frame(width:150)
                                    .onAppear {
                                        isNameFieldFocused = true
                                    }
                            }else{
                                Text(limitTextWithVisualWeight(playerName))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textColor)
                                    .frame(width:150)
                            }
                            
                            Button {
                                if isEditing {
                                    // フォーカスを外して編集終了
                                    isNameFieldFocused = false
                                }
                                isEditing.toggle()
                            } label: {
                                Text(isEditing ? "保存" : "編集")
                                    .font(.system(size: 14))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(Color.textColor)
                                    .background(isEditing ? Color.gray :Color.buttonColor)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                            }
                        }
                        
                        Rectangle()
                            .frame(width: 240, height: 1)
                            .foregroundColor(.gray)
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
            
//            // ZStack内で最前面に置くナビゲーション
//            BottomNavigationBar(
//                onCameraTap: { print("カメラタップ") },
//                onHomeTap: { print("ホームタップ") },
//                onMenuTap: { print("メニュータップ") }
//            )
//            .padding(.bottom, 30)
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


// 文字数を計算して重みの合計が10以下
func limitTextWithVisualWeight(_ text: String, maxVisualLength: Double = 10.0) -> String {
    var visualLength: Double = 0.0
    var result = ""
    
    for char in text {
        let weight: Double
        
        if ("\u{3040}"..."\u{309F}").contains(char) {
            weight = 1.5 // ひらがな
        } else if ("a"..."z").contains(char.lowercased()) {
            weight = 1.0 // アルファベット
        } else if char.isNumber {
            weight = 1.2 // 数字は中間くらい
        } else {
            weight = 2.0 // 漢字や記号など
        }
        
        if visualLength + weight > maxVisualLength {
            result += "…"
            break
        }
        
        visualLength += weight
        result.append(char)
    }
    
    return result
}

