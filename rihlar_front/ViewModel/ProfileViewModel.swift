//
//  ProfileViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/09.
//

import Foundation

/// Profile画面のデータ取得・保持・更新を担当する ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    /// 画面で表示するためにまとめたデータ（ユーザー・実績・写真）
    @Published var viewData: UserProfileViewData?
    
    /// editableNameをViewModelで管理する
    @Published var editableName: String = ""
    
    init() { } // 初期化処理は特に変更なし
    
    /// ユーザー情報をAPIから取得し、モックの実績・写真と合わせてViewDataに反映する
    func loadProfile() async {
        do {
            
            // ユーザー情報はAPIから取得
            let user = try await fetchCurrentUser()
            
            print("APIからユーザー情報を受け取りました:")
            print("ID: \(user.id)")
            print("名前: \(user.name)")
            print("アイコンURL: \(user.iconUrl?.absoluteString ?? "nil")")
            
            
            // ユーザー名をeditableNameに設定
            self.editableName = user.name
            // 実績と写真はこれまで通りモックデータを使用
            let records: [Record] = [mockRecord]
            let photos: [Photo] = mockPhotos
            
            
            // 画面に渡すデータとしてまとめる
            self.viewData = UserProfileViewData(
                user: user,
                records: records, // モックデータを渡す
                photos: photos    // モックデータを渡す
            )
        } catch {
            print("プロフィールの取得に失敗しました: \(error.localizedDescription)")
            // エラーハンドリング
            self.viewData = nil
        }
    }
    
    /// ユーザー名を更新する
    func updateUserName(newName: String) async {
        guard let currentUserID = viewData?.user.id else {
            print("ユーザーIDが取得できません。")
            return
        }
        do {
            // TODO: ここでAPIを呼び出してユーザー名を更新する実際のロジックを実装します。
            // APIからのレスポンスで更新されたユーザー情報（名前とアイコンを含む）を受け取ることを想定します。
            
            print("ユーザー名を \(newName) に更新を試みます。")
            if var user = viewData?.user {
                user.name = newName // nameプロパティを直接変更
                self.viewData?.user = user
                self.editableName = newName
            }
            print("ユーザー名が更新されました。")
        } catch {
            print("ユーザー名の更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    /// ユーザーアイコンを更新する
    func updateUserIcon(newIconUrl: URL?) async {
        guard let currentUserID = viewData?.user.id else {
            print("ユーザーIDが取得できません。")
            return
        }
        do {
            // TODO: ここでAPIを呼び出してユーザーアイコンを更新する実際のロジックを実装します。
            // APIからのレスポンスで更新されたユーザー情報（名前とアイコンを含む）を受け取ることを想定します。
            
            print("ユーザーアイコンを \(newIconUrl?.absoluteString ?? "nil") に更新を試みます。")
            if var user = viewData?.user {
                user.iconUrl = newIconUrl
                self.viewData?.user = user
            }
            print("ユーザーアイコンが更新されました。")
        } catch {
            print("ユーザーアイコンの更新に失敗しました: \(error.localizedDescription)")
        }
    }
}
