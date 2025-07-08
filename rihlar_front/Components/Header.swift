//
//  header.swift
//  rihlar_front
//
//  Created by Kodai Hirata on 2025/06/10.
//

import SwiftUI

struct Header: View {
    @ObservedObject var vm: GameViewModel
    let game: Game
    
    var body: some View {
        let mode: GameType = game.type
        
        if mode == .admin {
            VStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .stroke(color: Color("collection"), width: 2)
                        
                        VStack(spacing: -8) {
                            Text("コレクション")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("モード")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    .opacity(0)
                    if game.status == .inProgress {
                        Image("matchHeader")
                            .overlay(Text(remainingTimeString(until: game.endTime))
                                .foregroundColor(Color("TextColor"))
                                .font(.system(size: 16, weight: .bold))
                            )
                    } else {
                        Image("matchHeader")
                            .overlay(Text("対戦モード")
                                .foregroundColor(Color("TextColor"))
                                .font(.system(size: 16, weight: .bold))
                            )
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .stroke(color: Color("collection"), width: 2)
                        
                        Image("collectionIcon")
                        
                        VStack(spacing: -8) {
                            Text("コレクション")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("モード")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    .onTapGesture {
                        vm.toggleCurrentGameType()
                    }
                }
                
                if game.status == .notStarted && game.startTime <= Date() {
                    Notice(
                        label: "ゲームが開催されました！\n下のボタンからゲームに参加してください！",
                        graColor: Color(hex: "#FEE075"),
                        height: 40
                    )
                } else if game.status == .inProgress {
                    HStack(alignment: .top) {
                        PhotoThemes(theme: "動物")
                            .padding(.leading)
                        
                        Spacer()
                        
                        ScoreStatusPanel(rank: 10, currentScore: 0)
                            .padding(.trailing)
                    }
                }
            }
        } else {
            VStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .stroke(color: Color("collection"), width: 2)
                        
                        VStack(spacing: -8) {
                            Text("対戦")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                            
                            Text("モード")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .opacity(0)
                    
                    Image("collectionHeader")
                        .overlay(Text("コレクションモード")
                            .foregroundColor(Color("TextColor"))
                            .font(.system(size: 16, weight: .bold))
                        )
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .stroke(color: Color("match"), width: 2)
                        
                        Image("matchIcon")
                        
                        VStack(spacing: -8) {
                            Text("対戦")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("モード")
                                .stroke(color: Color.white, width: 1.4)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    .onTapGesture {
                        vm.toggleCurrentGameType()
                    }
                }
                
                if game.status == .notStarted && game.startTime <= Date() {
                    Notice(
                        label: "ゲームが開催されました！\n対戦モードに切り替えて！",
                        graColor: Color(hex: "#FEE075"),
                        height: 40
                    )
                }
            }
        }
    }
}
