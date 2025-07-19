//
//  PhotoEntity.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/19.
//

import Foundation

// 仮のPhotoモデル
struct PhotoEntity: Codable, Identifiable {
    let id: String
    let imageUrl: URL
    let title: String
}
