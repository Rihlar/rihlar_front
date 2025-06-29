//
//  Router.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/23.
//

import SwiftUI

// 画面遷移の管理
@MainActor
class Router: ObservableObject {
    @Published var path: [Route] = []
/// LoadingView からTopPageに戻って「陣取りスタート！」の文字を出すのに必要
    @Published var didStartFromLoading: Bool = false
    
    func push(_ route: Route) {
        path.append(route)
    }
    func pop() {
            _ = path.removeLast()
    }
    func reset() {
        path.removeAll()
    }
}
