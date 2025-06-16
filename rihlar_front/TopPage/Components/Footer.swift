//
//  footer.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/10.
//

import SwiftUI

struct Footer: View {
    var onCameraTap: () -> Void
    var onMenuTap: () -> Void
    
    var body: some View {
        HStack {
            FooterBtn(
                iconName: "cameraIcon",
                label: "カメラ",
                action: onCameraTap,
                padding: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
            )
            
            Spacer()
            
            FooterBtn(
                iconName: "menuIcon",
                label: "メニュー",
                action: onMenuTap,
                padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40)
            )
        }
    }
}

