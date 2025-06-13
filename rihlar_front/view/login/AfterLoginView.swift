//
//  AfterLoginView.swift
//  rihlar_front
//
//  Created by 川岸遥奈 on 2025/06/09.
//

import SwiftUI

struct LoginView: View {
    // 状態管理用の変数 code を宣言。ログイン時に取得するトークンを格納するため
    let code: String  
    
    var body: some View {
        NavigationView {
            VStack{
                Text("ログイン画面")
                    .font(.title)
                //                コンテンツを中央寄せ
                Spacer()
                                Text("ログイン済み")
                    //                    実際に取得した code（トークン文字列）を表示
                    Text("\(code)")
                
                Spacer()
                
                NavigationView {
                   VStack {
                       NavigationLink(destination: camera()) {
                           Text("次のページへ")
                               .padding()
                               .foregroundColor(.white)
                               .background(Color.blue)
                               .cornerRadius(10)
                       }
                   }
                   .navigationTitle("ホーム")
               }
            }
        }
    }
    
        
    }
    


