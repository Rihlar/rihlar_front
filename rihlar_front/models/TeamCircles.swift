//
//  TeamCircles.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/30.
//

import Foundation

/// 「Top1」「Top2」などキーも含めて View で使う型
struct TeamCircles: Identifiable {
    let groupName: String           // "Top1" など
    let teamID: String
    let circles: [CircleDataEntity]

    var id: String { groupName }
}

