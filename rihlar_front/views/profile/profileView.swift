//
//  profileView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/10.
//

import SwiftUI

struct ProfileView: View {
    // ViewModelを状態として保持
    @StateObject private var profileViewModel = ProfileViewModel()
    @ObservedObject var router: Router
    
    // ViewModelからeditableNameを受け取るようにする
    // @State private var editableName: String // 不要になるか、ViewModelの値を監視する
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    
    @State private var isEditing = false
    @FocusState private var isNameFieldFocused: Bool    // フォーカス管理
    
    // タップされた画像のインデックスを管理するState（Optional）
    @State private var selectedImageIndex: ImageIndex? = nil
    // ViewModelを状態として保持（画面に紐づく）
    @StateObject private var recordsViewModel = RecordsViewModel() // 名前の重複を避けるためrecordsViewModelに変更
    // 実績を選択する処理をするかどうか
    @State private var showAchievementSheet = false
    // 選択された実績だけ取り出して最大3つに制限
    var selectedRecords: [Record] {
        Array(recordsViewModel.records.filter { $0.isSelected }.prefix(3))
    }
    
    init(router: Router) {
        _router = ObservedObject(initialValue: router)
        // ここではprofileViewModel.viewDataがまだロードされていないため、editableNameの初期値は設定しない
        // editableNameはViewModelの@Publishedプロパティとして管理
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
                    
                    // ViewModelからアイコンURLを取得
                    AsyncImage(url: profileViewModel.viewData?.user.iconUrl) { image in
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
                            // ViewModelのeditableNameをTextFieldにバインド
                            if isEditing {
                                TextField("名前を入力", text: $profileViewModel.editableName)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .focused($isNameFieldFocused)
                                    .frame(width:150)
                                    .onAppear {
                                        isNameFieldFocused = true
                                    }
                            } else {
                                Text(limitTextWithVisualWeight(profileViewModel.editableName))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textColor)
                                    .frame(width:150)
                            }
                            
                            Button {
                                if isEditing {
                                    isNameFieldFocused = false
                                    // 保存ボタンが押されたらViewModelの更新メソッドを呼び出す
                                    Task {
                                        await profileViewModel.updateUserName(newName: profileViewModel.editableName)
                                    }
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
                
                // 実績バッジ (既存コードから変更なし)
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
                                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
                                }
                            }
                            .frame(width: 90, height: 90)
                            .contentShape(Rectangle())
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
                        // ViewModelのviewDataから写真情報を取得
                        ForEach(profileViewModel.viewData?.photos.indices ?? 0..<0, id: \.self) { index in
                            if let photo = profileViewModel.viewData?.photos[index] {
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
                    isChangeBtn.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
        }
        // Viewが表示されたときにユーザー情報をロード
        .onAppear {
            Task {
                await profileViewModel.loadProfile()
            }
        }
        .sheet(item: $selectedImageIndex) { imageIndex in
            // ViewModelから写真データを受け取る
            PhotoViewerView(photos: profileViewModel.viewData?.photos ?? [], startIndex: imageIndex.id)
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showAchievementSheet) {
            AchievementSelectionView(records: $recordsViewModel.records)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    ProfileView(router: Router()) // viewDataはViewModelが管理するためinitから削除
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
