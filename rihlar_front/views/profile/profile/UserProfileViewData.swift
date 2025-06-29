//
//  UserProfileViewData.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation
// 表示用にモデルをまとめたもの

struct UserProfileViewData {
    let user: User          // ユーザー情報
    let records: [Record]    // 実績情報
    let photos: [Photo]     // 写真情報
}

