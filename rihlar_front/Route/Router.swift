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
