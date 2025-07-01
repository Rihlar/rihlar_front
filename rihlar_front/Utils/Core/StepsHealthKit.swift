//
//  StepsHealthKit.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/01.
//

import Foundation
import HealthKit

@MainActor
final class StepsHealthKit: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var authorizationStatus: Bool = false
    @Published var todaySteps: Double? = nil

    // MARK: 認可リクエスト
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)
        else { return }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepType])
            authorizationStatus = true
        } catch {
            authorizationStatus = false
            debugPrint("認可エラー:", error)
        }
    }

    // MARK: 歩数取得
    func fetchTodaySteps() async {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            debugPrint("歩数タイプ取得失敗"); return
        }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: Date()
        )
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, stats, error in
            guard let sum = stats?.sumQuantity() else { return }
            let count = sum.doubleValue(for: .count())
            Task { @MainActor in
                self.todaySteps = count
            }
        }
        healthStore.execute(query)
    }

    // MARK: ——— 認可→歩数取得 を一気にやる
    func authorizeAndFetch() async {
        // １）権限リクエスト
        await requestAuthorization()
        // ２）許可が取れたら歩数取得
        if authorizationStatus {
            await fetchTodaySteps()
        }
    }
}

//    例
//    VStack(spacing: 16) {
//      if !hk.authorizationStatus {
//       MARK: ここを写真を撮るボタンなどにしたら写真を撮ると同時に認可→歩数取得ができると思う
//        Button("許可して歩数を取得") {
//          Task { await hk.authorizeAndFetch() }
//        }
//      } else {
//        // 一度許可済みならボタン押さずに自動取得
//        if let steps = hk.todaySteps {
//          Text("今日の歩数：\(Int(steps)) 歩")
//        } else {
//          Text("取得中…")
//            .onAppear {
//              Task { await hk.fetchTodaySteps() }
//            }
//        }
//      }
//    }
//    .padding()

