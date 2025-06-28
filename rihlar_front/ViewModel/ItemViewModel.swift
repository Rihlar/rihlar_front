//
//  ItemViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/28.
//
import Foundation
// アイテム一覧を管理するViewModel
@MainActor
class ItemViewModel {
    // View側で使うアイテム一覧
    @Published var items: [Item] = []
    
    // イニシャライザで仮データ読み込み
    init() {
        loadItems()
    }
    
    // 仮データを読み込み処理
    private func loadItems(){
        items = [
            Item(id: 1, name: "多分守るマン", count: 3, iconName: "drop"),
            Item(id: 2, name: "倍倍ふぁいと", count: 1, iconName: "key"),
            Item(id: 3, name: "嬉Cー", count: 1, iconName: "map"),
            Item(id: 4, name: "絶対押してマイルマン", count: 42, iconName: "bitcoinsign.circle"),
            Item(id: 5, name: "一向に構わん水", count: 0, iconName: "diamond"),
            Item(id: 6, name: "勘のいいガキー", count: 6, iconName: "diamond"),
            Item(id: 7, name: "命を刈り取るカマ", count: 0, iconName: "diamond")
        ]
    }
}
