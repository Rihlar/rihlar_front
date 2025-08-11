//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    let viewData: UserProfileViewData
    @ObservedObject var router: Router
    @State private var editableName: String
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    @State private var isEditing = false
    @FocusState private var isNameFieldFocused: Bool
    
    // 写真一覧を保持
    @StateObject private var photoViewModel = ProfileViewModel()
    
    // 選択中の画像インデックス
    @State private var selectedImageIndex: ImageIndex? = nil
    
    @StateObject private var viewModel = RecordsViewModel()
    @State private var showAchievementSheet = false
    
    // 実績最大3つまで
    var selectedRecords: [Record] {
        Array(viewModel.records.filter { $0.isSelected }.prefix(3))
    }
    
    init(viewData: UserProfileViewData, router: Router) {
        self.viewData = viewData
        _router = ObservedObject(initialValue: router)
        _editableName = State(initialValue: viewData.user.name)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 0)
                    .navigationBarBackButtonHidden(true)
                
                // プロフィール画像
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 120, height: 120)
                    AsyncImage(url: viewData.user.iconUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                }
                
                // 名前＋編集ボタン
                HStack(alignment: .center, spacing: 10) {
                    VStack(spacing: 5) {
                        HStack {
                            if isEditing {
                                TextField("名前を入力", text: $editableName)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .focused($isNameFieldFocused)
                                    .frame(width:150)
                                    .onAppear {
                                        isNameFieldFocused = true
                                    }
                            } else {
                                Text(limitTextWithVisualWeight(editableName))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textColor)
                                    .frame(width:150)
                            }
                            
                            Button {
                                if isEditing {
                                    isNameFieldFocused = false
                                }
                                isEditing.toggle()
                            } label: {
                                Text(isEditing ? "保存" : "編集")
                                    .font(.system(size: 14))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(Color.textColor)
                                    .background(isEditing ? Color.itemBackgroundColor : Color.buttonColor)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                            }
                        }
                        
                        Rectangle()
                            .frame(width: 236, height: 1)
                            .foregroundColor(Color.separatorLine)
                    }
                }
                
                // 実績バッジ
                Button {
                    showAchievementSheet = true
                } label: {
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 90, height: 90)
                                if index < selectedRecords.count {
                                    let record = selectedRecords[index]
                                    Group {
                                        if record.imageUrl.contains("http"),
                                           let url = URL(string: record.imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFill()
                                            } placeholder: {
                                                Color.white
                                            }
                                        } else {
                                            Image(record.imageUrl)
                                                .resizable()
                                                .scaledToFill()
                                        }
                                    }
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 70, height: 70)
                                        .shadow(color: Color.black.opacity(0.05), radius: 1)
                                }
                            }
                            .frame(width: 90, height: 90)
                        }
                    }
                    .padding()
                    .background(Color.recordBackgroundColor)
                    .frame(width:300,height:90)
                    .cornerRadius(20)
                }
                
                // 記録した写真
                Text("記録した写真")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.textColor)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(Array(photoViewModel.photos.indices), id: \.self) { index in
                            let photo = photoViewModel.photos[index]
                            
                            Group {
                                if let url = URL(string: photo.url) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                            }
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedImageIndex = ImageIndex(id: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
                .task {
                    await photoViewModel.loadPhotos()
                }
            }
            
            if isShowMenu {
                Color.white.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Menu(router: router)
                    .transition(
                        .move(edge: .trailing)
                        .combined(with: .opacity)
                    )
            }
            
            BottomNavigationBar(
                router: router,
                isChangeBtn: isChangeBtn,
                onCameraTap: {
                    router.push(.camera)
                },
                onMenuTap: {
                    isChangeBtn.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
        }
        .sheet(item: $selectedImageIndex) { (imageIndex: ImageIndex) in
            PhotoViewerView(photos: photoViewModel.photos, startIndex: imageIndex.id)
        }
        .sheet(isPresented: $showAchievementSheet) {
            AchievementSelectionView(records: $viewModel.records)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

// ImageIndex 構造体
struct ImageIndex: Identifiable {
    let id: Int
}
#Preview {
    ProfileView(viewData: mockUserProfile,router:  Router())
}


/// 文字数を計算して幅の合計が maxVisualLength を超えないようトリミングし、
/// はみ出す場合は末尾に「…」を追加
func limitTextWithVisualWeight(_ text: String,
                               maxVisualLength: Double = 10.0) -> String {
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
