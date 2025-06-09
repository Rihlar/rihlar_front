//
//  topPage.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/06.
//

import SwiftUI
import CoreLocation

struct topPage: View {
    /// LocationManager を @StateObject で生成
    @StateObject private var locationManager = LocationManager()
    
    let circleCenters: [CLLocationCoordinate2D] = []
    
    var body: some View {
        ZStack {
            CircleMap(
                locationManager: locationManager,
                circleCenters: circleCenters
            )
            .ignoresSafeArea()
            
            VStack {
                Button {
                    locationManager.resumeFollow()
                } label: {
                    Image(systemName: "bookmark.fill")
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding()
            }

        }
    }
}

#Preview {
    topPage()
}
