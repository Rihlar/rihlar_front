//
//  profilwMock.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// User モック
let mockUser = User(
    id: "9abfba53-7e49-4204-9928-73431039ca34",
    name: "川岸 遥奈"
)

// Record モック
let mockRecord = Record(
    id: 1,
    title: "100スポット達成！",
    description: "100か所のスポットに訪問しました！",
    imageUrl:"king"
)

// Photo モック
let mockPhotos: [Photo] = [
    Photo(
        id: "img1",
        url: "tennpure1",
        theme: "猫",
        createdAt: Date()
    ),
    Photo(
        id: "img2",
        url: "tennpure2",
        theme: "いちご",
        createdAt: Date().addingTimeInterval(-86400)
    )
]

// UserProfileViewData モック
let mockUserProfile = UserProfileViewData(
    user: mockUser,
    records:[mockRecord],
    photos: mockPhotos
)

