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
        Record(id: 1, title: "100km歩いた", imageUrl: "king", isSelected: true),
        Record(id: 2, title: "10000ポイント",  imageUrl: "king", isSelected: true),
        Record(id: 3, title: "写真100枚", imageUrl: "king", isSelected: true),
        Record(id: 4, title: "7日連続",  imageUrl: "king", isSelected: true),
        Record(id: 5, title: "個人戦5勝",  imageUrl: "king", isSelected: true),
        Record(id: 6, title: "チーム戦5勝",  imageUrl: "king", isSelected: true),
        Record(id: 7, title: "アイテム10個",  imageUrl: "king", isSelected: true)
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
