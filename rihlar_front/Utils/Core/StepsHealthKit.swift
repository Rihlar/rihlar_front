//
//  StepsHealthKit.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/07/01.
//

import HealthKit
import Combine

/// HealthKit を使ってユーザーの歩数を取得し、公開するクラス
/// - Combine の @Published で UI バインディング可能
final class StepsHealthKit: ObservableObject {
    // MARK: - 公開プロパティ
    /// 現在のステップ合計を保持。変更時に SwiftUI に通知。
    @Published private(set) var steps: Int = 0

    // MARK: - HealthKit 管理
    /// HealthKit ストアへの参照
    private let store = HKHealthStore()
    /// 統計クエリを保持
    private var query: HKStatisticsCollectionQuery?

    // MARK: - 初期化
    init() {
        // 1) 読み取り権限をリクエスト
        // HKQuantityTypeIdentifier.stepCount の読み取り許可が必要
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        store.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            // 成否は必要に応じてハンドル
        }
        // 2) クエリをセットアップして実行
        startStepQuery()
    }

    // MARK: - クエリのセットアップ
    /// 日付単位で累積歩数を取得するクエリを作成し、初回と更新時のハンドラを設定
    private func startStepQuery() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        // 00:00 をアンカーデートにして日単位で集計
        let anchor = Calendar.current.startOfDay(for: now)
        let interval = DateComponents(day: 1)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,        // フィルタなし
            options: [.cumulativeSum],           // 合計値を算出
            anchorDate: anchor,
            intervalComponents: interval
        )
        // 初回実行時のコールバック
        query.initialResultsHandler = { _, results, error in
            self.updateSteps(from: results, to: now)
        }
        // データ更新時のコールバック
        query.statisticsUpdateHandler = { _, _, results, error in
            self.updateSteps(from: results, to: now)
        }
        // クエリを実行して結果を受け取り始める
        store.execute(query)
        // メンバーに保持しておく
        self.query = query
    }

    // MARK: - 結果処理
    /// 統計結果から指定時刻までの累積歩数を取得し、@Published プロパティに反映
    private func updateSteps(from stats: HKStatisticsCollection?, to end: Date) {
        guard let stats = stats,
              // 指定日時の統計を取得
              let sum = stats.statistics(for: end)?
                           .sumQuantity()?
                           .doubleValue(for: HKUnit.count())
        else { return }
        // UI 更新はメインスレッドで
        DispatchQueue.main.async {
            self.steps = Int(sum)
        }
    }
}
