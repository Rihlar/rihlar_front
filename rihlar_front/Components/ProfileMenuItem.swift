//
//  ProfileMenuItem.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/19.
//

import SwiftUI

struct ProfileMenuItem: View {
    //    タップ時に呼ばれるクロージャ
    var action: () -> Void
    var userName: String // ユーザー名
    var userIcon: URL?   // ユーザーアイコンURL
    var records: [Record]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color("collection"))
                .frame(width: 340, height: 90)
                .clipShape(
                    //                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color("BtnColor"))
                .frame(width: 337, height: 86)
                .clipShape(
                    //                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50)
                )
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
            
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: 330, height: 75)
                .clipShape(
                    //                    角丸を別ファイルで作成
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50)
                )
            //                グラデーションを別ファイルで作成
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 50),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)
            
            HStack(spacing: 20) {
                // ユーザーアイコン
                if let userIcon = userIcon {
                    CircularImage(imageName: userIcon.absoluteString, diameter: 70)
                }
                
                VStack {
                    Text(userName)
                        .font(.system(size: 16, weight: .bold))
                        .padding(EdgeInsets(top: 0, leading: -52, bottom: 0, trailing: 0))
                    
                    //                    称号のアイコンが3つ
                    HStack {
                        ForEach(records.prefix(3)) { record in
                            CircularImage(imageName: record.imageUrl, diameter: 30)
                        }
                    }
                }
                
                Image("rightArrowIcon")
                    .padding(EdgeInsets(top: 0, leading: 80, bottom: 0, trailing: 0))
            }
        }
        .contentShape(Rectangle())      // クリック領域を明確に
        .onTapGesture {
            action()                   // タップされたら action を呼び出す
        }
    }
}

struct ProfileMenuView: View {
    @State private var user: User? = nil  // ユーザー情報を保持する変数
    @State private var isLoading: Bool = true  // ローディング中かどうかの状態
    @StateObject private var recordsViewModel = RecordsViewModel()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")  // ローディング中はインジケーターを表示
            } else if let user = user {
                // ユーザー情報が取得できた場合、ProfileMenuItem にデータを渡す
                ProfileMenuItem(action: {
                    // タップしたときの動作
                }, userName: user.name, userIcon: user.iconUrl,records: recordsViewModel.records.filter { $0.isSelected })
            } else {
                Text("ユーザー情報が取得できませんでした")  // 取得できなかった場合のエラーメッセージ
            }
        }
        .onAppear {
            Task {
                do {
                    // 非同期でユーザー情報を取得
                    user = try await fetchUserProfile()
                    isLoading = false
                } catch {
                    isLoading = false
                    print("ユーザー情報の取得に失敗しました: \(error)")
                }
            }
        }
    }
}
