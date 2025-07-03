//
//  friendRecords.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/03.
//

// 実績のモック
enum FriendRecords {
    // モック実績データ（アセット名は "king" を共通使用）
    static let FriendMockRecords: [Record] = [
        Record(id: 1, title: "100km歩いた", description: "100km達成", imageUrl: "king", isSelected: true),
        Record(id: 2, title: "10000ポイント", description: "ポイント獲得", imageUrl: "king", isSelected: true),
        Record(id: 3, title: "写真100枚", description: "写真を100枚撮影", imageUrl: "king", isSelected: true),
        Record(id: 4, title: "7日連続", description: "連続で記録", imageUrl: "king", isSelected: true),
        Record(id: 5, title: "個人戦5勝", description: "勝利実績", imageUrl: "king", isSelected: true),
        Record(id: 6, title: "チーム戦5勝", description: "チームで勝利", imageUrl: "king", isSelected: true),
        Record(id: 7, title: "アイテム10個", description: "たくさん集めた", imageUrl: "king", isSelected: true)
    ]
    
    // フレンドデータ（3件ずつ渡す）
    static var mockFriends: [FriendData] {
        [
            FriendData(name: "はるるん", imageName: "user", records: Array(FriendMockRecords[0..<3])),
            FriendData(name: "こだっち", imageName: "user", records: Array(FriendMockRecords[3..<6])),
            FriendData(name: "りこぴん", imageName: "user", records: Array(FriendMockRecords[4..<7]))
        ]
    }
}
