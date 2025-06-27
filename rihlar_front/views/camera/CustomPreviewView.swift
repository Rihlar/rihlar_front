// CustomPreviewView.swift
import SwiftUI
import CoreLocation

struct CustomPreviewView: View {
    let image: UIImage
    let location: CLLocation?
    let onRetake: () -> Void
    let onUse: () -> Void

    var body: some View {
        ZStack {
            // 背景：撮った写真をフルスクリーン表示
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // 左上の小窓（必要なら前カメラ画像を渡すよう拡張）
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 140)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 2))
                    
                    Spacer()
                    
                    // 閉じるボタン or RetakeボタンにしてもOK
                    Button(action: onRetake) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Spacer()
                
                // 下部ボタン群
                HStack(spacing: 12) {
                    Label("私の友達のみ", systemImage: "person.2.fill")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    if let loc = location {
                        Label("現在地", systemImage: "location.fill")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                    }
                    
                    Image(systemName: "music.note")
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 80)
                
                // 送信（Use）ボタン
                Button(action: onUse) {
                    Text("送信 ▶︎")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
