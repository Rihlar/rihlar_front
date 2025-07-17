//
//  makeUserProfileViewData.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/07/17.
//

func makeUserProfileViewData() async throws -> UserProfileViewData {
    let user = try await fetchUserProfile()

    return UserProfileViewData(
        user: user,
        records: [mockRecord],   // ← モック実績
        photos: mockPhotos       // ← モック写真
    )
}
