//
//  remainingTimeString.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/29.
//

import Foundation

/// 残り時間を文字列で返す
func remainingTimeString(until end: Date) -> String {
    let now = Date()
    // 現在時刻がすでに過ぎていれば「終了」と返す
    guard end > now else { return "終了" }

    // 日・時間・分を取得
    let comps = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: end)

    if let days = comps.day, days >= 1 {
        // 24時間以上なら日数
        return "\(days)日後"
    } else {
        // 24時間未満なら時間＋分
        let hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        if hours >= 1 {
            return "\(hours)時間\(minutes)分後"
        } else {
            return "\(minutes)分後"
        }
    }
}

