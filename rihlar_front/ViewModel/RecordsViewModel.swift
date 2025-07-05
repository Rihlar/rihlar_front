//
//  RecordsViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/05.
//

import Foundation

// 実績一覧を管理するView
@MainActor
class RecordsViewModel: ObservableObject {
    // View側で使うアイテム
    @Published var records: [Record] = []
    
    // イニシャライザで仮データの読み込み
    init() {
        recordsData()
    }
    
    // 仮データ
    private func recordsData(){
        records =  [
            Record(id: 1, title: "100km歩く", imageUrl: "100km", isSelected: false),
            Record(id: 2, title: "10,000pt獲得", imageUrl: "10000pt", isSelected: true),
            Record(id: 3, title: "写真を100枚撮る", imageUrl: "100photo", isSelected: true),
            Record(id: 4, title: "7日間連続で写真を撮る", imageUrl: "7daysphoto", isSelected: false),
            Record(id: 5, title: "陣取りゲーム 個人戦で5勝する", imageUrl: "soro5win", isSelected: false),
            Record(id: 6, title: "陣取りゲーム チーム戦で5勝する", imageUrl: "team5win", isSelected: true),
            Record(id: 7, title: "アイテムを5個獲得", imageUrl: "5item", isSelected: false)

            
        ]
    }
    
}
