//
//  ContentView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/05/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
               NavigationLink {
                LoginView()
            } label: {
                Text("next testAview")
            }
            
        }.task {
            do {
                print("fetch info")
                print(await try fetchInfo())
            } catch {
            }
        }
    }
}

#Preview {
    ContentView()
}
