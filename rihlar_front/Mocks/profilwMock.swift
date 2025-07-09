// profilwMock.swift
// rihlar_front
//
// Created by 川岸遥奈 on 2025/06/29.
//

import Foundation

// User モック (APIから取得するため、通常は使わないが、プレビュー用に定義しても良い)
// ただし、ProfileViewModelはfetchCurrentUser()を使うので、このmockUserは直接は使われません
let mockUser = User(
    id: "a39f14c3-61b2-48f8-9cc3-b3f7e25b64a0",
    name: "はるるん",
    email: "waaaa@example.com",
    provCode: "google",
    provUid: "some_prov_uid",
    iconUrl: URL(string: "https://rihlar.kokomeow.com/auth/assets/a39f14c3-61b2-48f8-9cc3-b3f7e25b64a0.png")
)

// Record モック (変更なし、引き続き使用)
let mockRecord = Record(
    id: 1,
    title: "100スポット達成！",
    imageUrl:"king",
    isSelected: false
)

// Photo モック (変更なし、引き続き使用)
let mockPhotos: [Photo] = [
    Photo(
        id: "img1",
        url: "tennpure1",
        theme: "猫",
        createdAt: Date().addingTimeInterval(-0)
    ),
    Photo(
        id: "img2",
        url: "tennpure2",
        theme: "いちご",
        createdAt: Date().addingTimeInterval(-1000)
    ),
    Photo(
        id: "img3",
        url: "tennpure3",
        theme: "スイーツ",
        createdAt: Date().addingTimeInterval(-2000)
    ),
    Photo(
        id: "img4",
        url: "tennpure4",
        theme: "ラーメン",
        createdAt: Date().addingTimeInterval(-3000)
    ),
    Photo(
        id: "img5",
        url: "tennpure5",
        theme: "そら",
        createdAt: Date().addingTimeInterval(-4000)
    ),
    Photo(
        id: "img6",
        url: "tennpure6",
        theme: "バイク",
        createdAt: Date().addingTimeInterval(-5000)
    ),
    Photo(
        id: "img7",
        url: "tennpure7",
        theme: "犬",
        createdAt: Date().addingTimeInterval(-6000)
    ),
    Photo(
        id: "img8",
        url: "tennpure8",
        theme: "ご飯",
        createdAt: Date().addingTimeInterval(-7000)
    ),
    Photo(
        id: "img9",
        url: "tennpure9",
        theme: "ぬいぐるみ",
        createdAt: Date().addingTimeInterval(-8000)
    ),
]

// UserProfileViewData モック (プレビュー用に必要)
// ユーザー情報もプレビュー用に必要なので、mockUser を使用します。
let mockUserProfile = UserProfileViewData(
    user: mockUser,      // ここに mockUser を指定
    records:[mockRecord],
    photos: mockPhotos
)
