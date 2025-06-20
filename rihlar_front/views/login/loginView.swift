//
//  loginView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/09.
//

import SwiftUI


// 一つのバブルの定義
struct Bubble: Identifiable {
    let id = UUID()
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let delay: Double
    let color: Color
}


// 単体バブルのビュー
struct BubbleView: View {
    @State private var animate = false
    let bubble: Bubble
    
    var body: some View {
        Circle()
        // 円の中身は透過（透明）にする
            .fill(Color.clear)
            .frame(width: bubble.size, height: bubble.size)
        // 縁（Stroke）だけをオーバーレイとして表示し、
        // 縁の不透明度とスケールをアニメーションで変化させる
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(animate ? 1 : 0), lineWidth: 3)  // 白の縁の線幅3pt
                    .scaleEffect(animate ? 1.0 : 0.5)  // 縁のスケール変化（小→大）
                    .animation(
                        .easeOut(duration: 1.5)  // イージングとアニメーション時間
                            .delay(bubble.delay),    // 各バブルにランダムな遅延を付与
                        value: animate
                    )
            )
        // バブルの画面上の表示位置をランダム指定
            .position(x: bubble.x, y: bubble.y)
        // バブル全体のスケールも同様にアニメーションさせている（重複してるかも）
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.8)
            .animation(
                .easeOut(duration: 1.5)
                .delay(bubble.delay),
                value: animate
            )
        // View表示時にアニメーション開始
            .onAppear {
                animate = true
            }
    }
}

// バブルをランダムに背景に表示
struct BackgroundBubblesView: View {
    // バブルの色候補（使ってないが保持）
    let colors = [
        Color.red.opacity(0.5),
        Color.blue.opacity(0.5),
        Color.green.opacity(0.5)
    ]
    
    // 12個のバブルをランダム生成
    let bubbles: [Bubble] = (0..<12).map { _ in
        Bubble(
            size: CGFloat.random(in: 50...150),            // バブルの大きさランダム
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),  // x座標ランダム
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height), // y座標ランダム
            delay: Double.random(in: 0...2),                // アニメーション開始遅延ランダム
            color: [Color.red.opacity(0.5), Color.blue.opacity(0.5), Color.green.opacity(0.5)].randomElement()! // カラーランダム（今は未使用）
        )
    }
    
    var body: some View {
        ZStack {
            // バブル配列の全てのバブルをBubbleViewで描画
            ForEach(bubbles) { bubble in
                BubbleView(bubble: bubble)
            }
        }
    }
}

struct loginDesignView: View {
    // 状態管理用の変数 code を宣言。ログイン時に取得するトークンを格納するため
    @State private var code: String?
    //    グラデーションカラーの定義
    let gradient = Gradient(stops: [.init(color:  Color(red: 254/255, green: 224/255, blue: 117/255),  location: 0.2), .init(color: Color(red: 152/255, green: 186/255, blue: 135/255), location: 0.5)])
    var body: some View {
        NavigationStack {
            ZStack {
                // グラデーション
                LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                // バブル
                BackgroundBubblesView()
                
                VStack {
                    
                    
                    Text("ロゴ")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    
                    
                    NavigationLink {
                        
                        if let code = self.code{
                            LoginView(code: code)
                        }else {
                            
                            // カスタムビュー AuthSessionView を呼び出して、ログイン処理
                            AuthSessionView{
                                // クロージャとして callbackURL を受け取っています（おそらくOAuthやURLスキームによる認証結果）
                                callbackURL in
                                
                                self.code = getCode(callbackURL: callbackURL)
                                // self は、今の構造体やクラスの中で使っている自分自身
                                //                         self.code = 状態変数 code（@State）の中身
                                // 認証後に受け取ったURLからトークンを抽出して、code にセット
                            }
                            
                        }
                        
                        
                    } label: {
                        // googleボタン
                        HStack {
                            Image("googleIcon")
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("Googleアカウントでログイン")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        // ボタンデザイン
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 2)
                        )
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
    }}


// 認証結果で受け取ったURLから トークン（token）を抽出 する関数
func getCode(callbackURL: URL) -> String? {
    // デバッグ用にURLを出力
    print(callbackURL)
    
    // URLを構造的に解析し、クエリパラメータを取り出す
    // callbackURL は、ログイン後などにアプリが受け取る URL
    // guard＝早期リターンに使われる
    guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
          // queryItems は、URLの「?以降のパラメータ一覧」を [URLQueryItem] で取り出すプロパティ
          let queryItems = components.queryItems else {
        // 失敗したら nil を返すことでアプリがクラッシュしないように
        return nil
    }
    if let codeValue = queryItems.first(where: { $0.name == "token" })?.value{
        print("Code value:\(codeValue)")
        
        //　KeyChain（キーチェーン）は、Appleの提供する安全なデータ保存領域で、ログイントークンやパスワードなどの機密情報を保存する
        saveKeyChain(tag: "authToken", value: codeValue)
        // 取得したトークンを返す
        return codeValue
        
    }else{
        // token が見つからない場合は nil
        return nil
    }
    
    
}

#Preview {
    loginDesignView()
}
