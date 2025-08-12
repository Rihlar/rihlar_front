//
//  profilwMock.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// User モック
let mockUser = User(
    id: "ebab9786-8243-4f75-9699-136ff6044e39",
    name: "いろいろアカウント",
    email: "shareacount62@gmail.com",
    provCode: "google",
    provUID: "108057354938704198788"
)

// Record モック
let mockRecord = Record(
    id: 1,
    title: "100スポット達成！",
    imageUrl:"king",
    isSelected: false
)

// Photo モック
let mockPhotos: [Photo] = [
    
    
    
    
    
]

// UserProfileViewData モック
let mockUserProfile = UserProfileViewData(
    user: mockUser,
    records:[mockRecord],
    photos: mockPhotos
)

