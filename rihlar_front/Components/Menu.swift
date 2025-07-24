//
//  Menu.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/17.
//

import SwiftUI

struct Menu: View {
    @ObservedObject var router: Router
    @State private var isPressed = false
    @State private var user: User? = nil
    @StateObject private var recordsViewModel = RecordsViewModel()

    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(spacing: -16) {
                    if let user = user {
                        ProfileMenuItem(
                            action: { router.push(.profile) },
                            userName: user.name,
                            userIcon: user.iconUrl,
                            records: recordsViewModel.records.filter { $0.isSelected }
                        )
                        .zIndex(10)
                    }
                    
                    
                    MenuList(router: router)
                        .zIndex(1)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    
                }
            }
            Spacer()
        }
        .onAppear {
                    Task {
                        do {
                            user = try await fetchUserProfile()
                        } catch {
                            print("ユーザー情報の取得に失敗しました: \(error)")
                        }
                    }
                }
    }
}
