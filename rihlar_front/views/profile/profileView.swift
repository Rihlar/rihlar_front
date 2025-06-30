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
    @FocusState private var isNameFieldFocused: Bool    // フォーカス管理
    
    // タップされた画像のインデックスを管理するState（Optional）
    @State private var selectedImageIndex: ImageIndex? = nil
    // 実績を選択する処理をするかどうか
    @State private var showAchievementSheet = false
    // 実績を選択式に
    @State private var records: [Record]
    // 選択された実績だけ取り出して最大3つに制限
    var selectedRecords: [Record] {
        Array(records.filter { $0.isSelected }.prefix(3))
    }
    
    init(viewData: UserProfileViewData, router: Router) {
        self.viewData = viewData
        // ObservedObject の初期化にはプロパティラッパーの _router を使います
        _router = ObservedObject(initialValue: router)
        _editableName = State(initialValue: viewData.user.name)
        _records = State(initialValue: viewData.records)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 0)
                // back表示を消す
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
                
                // ユーザーネーム＋編集ボタン
                HStack(alignment: .center, spacing: 10) {
                    VStack(spacing: 5) {
                        HStack{
                            // 入力時と表示時で変化
                            if isEditing{
                                TextField("名前を入力",text: $editableName)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .focused($isNameFieldFocused)
                                    .frame(width:150)
                                    .onAppear {
                                        isNameFieldFocused = true
                                    }
                            }else{
                                Text(limitTextWithVisualWeight(editableName))
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
                                    .background(isEditing ? Color.itemBackgroundColor :Color.buttonColor)
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
                    HStack(spacing: 20) {
                        
                        ForEach(0..<3, id: \.self) { index in
                            ZStack {
                                // 常に白丸の枠だけは表示
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
                                
                                // 選択済みの実績があれば画像を表示
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
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                }
                            }
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
                
                // 写真一覧（下にスペース追加）
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(viewData.photos.indices, id: \.self) { index in
                            let photo = viewData.photos[index]
                            
                            Group {
                                if photo.url.contains("http"),
                                   let url = URL(string: photo.url) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                } else {
                                    Image(photo.url)
                                        .resizable()
                                        .scaledToFill()
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
                    //   ボタンの見た目切り替えは即時（アニメなし）
                    isChangeBtn.toggle()
                    
                    //　　メニュー本体の表示はアニメーション付き
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
            
        }
        //selectedImageIndexがセットされたら、対応する画像からPhotoViewerViewをsheet表示
        .sheet(item: $selectedImageIndex) { imageIndex in
            
            PhotoViewerView(photos: viewData.photos, startIndex: imageIndex.id)
                .presentationDragIndicator(.hidden)
        }
        
        
        
        
        .sheet(isPresented: $showAchievementSheet) {
            AchievementSelectionView(records: $records)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
}
#Preview {
    ProfileView(viewData: mockUserProfile,router:  Router())
}
// ImageIndex構造体はIdentifiableに準拠し、sheetのitemバインディング用に使う
struct ImageIndex: Identifiable {
    let id: Int
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
