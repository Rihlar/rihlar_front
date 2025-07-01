import SwiftUI

struct OrangeBtn: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    let isBigBtn: Bool

    var body: some View {
        ZStack {
            // 外枠（縁）
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.subuBtnLineColor)
                .frame(width: width, height: height)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: isBigBtn ? 20 : 16)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5)

            // メイン背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.subuBtnColor)
                .frame(width: width - 4, height: height - 4)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: isBigBtn ? 20 : 16)
                )

            // 光沢レイヤー
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.2))
                .frame(width: isBigBtn ? width - 20 : width - 15, height: isBigBtn ? height - 20 : height - 15)
                .clipShape(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15)
                )
                .overlayLinearGradient(
                    mask: RoundedCornerShape(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: 15),
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0)
                    ],
                    angle: .degrees(77)
                )
                .blur(radius: 10)

            // テキスト
            Text(label)
                .font(.system(size: isBigBtn ? 20 : 16, weight: .bold))
                .foregroundColor(.white)
                .stroke(color: Color.textColor, width: 0.8)
        }
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    OrangeBtn(
        label: "フレンドを追加",
        width: 240,
        height: 70,
        action: {
            print("フレンドを追加 tapped")
        },
        isBigBtn: true
    )
}
