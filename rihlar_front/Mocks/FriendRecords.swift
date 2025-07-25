//
//  friendRecords.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/03.
//

// 実績のモック
enum FriendRecords {
    // 名前リストだけ用意
    static let friendNames = [
        "はるるん",
        "こだっち",
        "りこぴん",
        "さくら",
        "たろう",
        "ゆかり",
        "まこと",
        "みさき",
    ]
    
    // recordsからランダムに3件選んで友達データを作るメソッド
    static func makeMockFriends(from records: [Record]) -> [FriendData] {
        friendNames.map { name in
            // recordsから3件ランダムに選択（重複なし）
            let randomRecords = records.shuffled().prefix(3)
            return FriendData(name: name, imageName: "user", records: Array(randomRecords))
        }
    }
}

