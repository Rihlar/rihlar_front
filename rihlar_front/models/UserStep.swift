//
//  UserStep.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/05.
//

import Foundation

struct UserStep: Codable, Identifiable, Equatable {
    let latitude:  Double   // 緯度
    let longitude: Double   // 経度
    let steps:     Int      // 歩数
    let timeStamp: Int      // UNIX タイムスタンプ（秒）
    
    var id: Int { timeStamp }
}
