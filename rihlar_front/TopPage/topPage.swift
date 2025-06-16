//
//  topPage.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/06.
//

import SwiftUI
import CoreLocation

struct topPage: View {
    @StateObject private var locationManager = LocationManager()
    @State private var circles: [CircleData] = []
    @State private var isShowCamera = false
    
    var body: some View {
        ZStack {
            CircleMap(locationManager: locationManager, circles: circles)
                        .ignoresSafeArea()
                        .onAppear {
                            loadSampleJSON()
                        }
            
            VStack {
                header()
                
                Spacer()
                
                Button {
                    locationManager.resumeFollow()
                } label: {
                    Image(systemName: "bookmark.fill")
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                HStack {
                    footer {
                        isShowCamera = true
                    }
                }
            }
        }
        .sheet(isPresented: $isShowCamera) {
//            test()をカメラのページに変更するとトップページとカメラが繋がる
//            test()を書き換えたらコメントアウトは消してください
                    test()
                }
    }
    
    private func loadSampleJSON() {
        let jsonString = """
        [
          {
            "latitude": 34.702485,
            "longitude": 135.495951,
            "size": 100
          },
          {
            "latitude": 34.7054,
            "longitude": 135.4983,
            "size": 5000
          },
          {
            "latitude": 34.71603,
            "longitude": 135.44979,
            "size": 50000
          }
        ]
        """
        // JSON文字列を Data に
        guard let data = jsonString.data(using: .utf8) else { return }

        do {
            // 単一オブジェクトなので CircleData.self
            let decoded = try JSONDecoder().decode([CircleData].self, from: data)
            circles = decoded
        } catch {
            print("JSON デコード失敗:", error)
        }
    }
}
