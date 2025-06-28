//
//  ItemViewModel.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/28.
//
import Foundation
// アイテム一覧を管理するViewModel
@MainActor
class ItemViewModel: ObservableObject{
    // View側で使うアイテム一覧
    @Published var items: [Item] = []
    
    // イニシャライザで仮データ読み込み
    init() {
        loadItems()
    }
    
    // 仮データを読み込み処理
    private func loadItems(){
        items = [
            Item(id: 1, name: "多分守るマン", count: 3, iconName: "tabunman",description: "円を守る(効果時間は2時間？)"),
            Item(id: 2, name: "倍倍ふぁいと", count: 1, iconName: "fight",description: "円のポイント二倍"),
            Item(id: 3, name: "嬉Cー", count: 1, iconName: "C-",description: "コインの獲得量2倍"),
            Item(id: 4, name: "絶対押してマイルマン", count: 42, iconName: "zettaiman",description: "円を絶対に取れる 多分守るマンより強い 激レア"),
            Item(id: 5, name: "一向に構わん水", count: 0, iconName: "water",description: "全ての状態異常をキャンセル 自分に向けたバフも消滅"),
            Item(id: 6, name: "勘のいいガキー", count: 6, iconName: "gaki-",description: "運営からの指定写真のヒントが 他の人より先に見える"),
            Item(id: 7, name: "命を刈り取るカマ", count: 0, iconName: "kama",description: "相手のポイント削る")
        ]
    }
}
