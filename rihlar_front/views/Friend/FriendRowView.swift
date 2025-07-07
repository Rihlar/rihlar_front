//
//  FriendRowView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/30.
//

import SwiftUI

struct FriendRowView: View {
    let userName: String
    let userImageName: String
    let records: [Record]
    
    var selectedRecords: [Record] {
        records.filter { $0.isSelected }.prefix(3).map { $0 }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // ユーザーアイコン
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 60, height: 60)
                
                Image(userImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            
            
            Text(userName)
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.black.opacity(0.05), radius: 1)
                        
                        if index < selectedRecords.count {
                            let record = selectedRecords[index]
                            Image(record.imageUrl)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
