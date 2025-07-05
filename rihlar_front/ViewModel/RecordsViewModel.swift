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
            
        ]
    }
    
}
