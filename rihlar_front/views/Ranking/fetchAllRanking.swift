import SwiftUI

// ランキングページ 親ビュー：userId, gameIdを非同期取得してから本体表示
struct SoloRankingView: View {
    @ObservedObject var router: Router
    
    @State private var userId: String? = nil
    @State private var gameId: String? = nil
    
    var body: some View {
        Group {
            if let userId = userId, let gameId = gameId {
                RankingContentView(router: router, userId: userId, gameId: gameId)
            } else {
                VStack {
                    ProgressView()
                    Text("ランキング情報を取得中…")
                }
                .task {
                    await loadUserAndGameInfo()
                }
            }
        }
        .background(Color(Color.backgroundColor).ignoresSafeArea())
    }
    
    private func loadUserAndGameInfo() async {
        do {
            // ユーザープロフィールはリフレッシュトークン（authToken）で取得する想定なので、fetchUserProfileはそのまま呼ぶ
            let user = try await fetchUserProfile()

            // ゲーム情報取得用アクセストークンはTokenManagerを使って取得
            let accessToken = try await TokenManager.shared.fetchAndCacheAccessToken()

            let gameInfo = try await fetchGameInfo(token: accessToken)

            DispatchQueue.main.async {
                self.userId = user.id
                self.gameId = gameInfo.admin?.gameID ?? gameInfo.system.gameID
            }
        } catch {
            print("ユーザ・ゲーム情報取得失敗:", error)
        }

    }
}


/// ランキング画面本体
struct RankingContentView: View {
    @ObservedObject var router: Router
    let userId: String
    let gameId: String
    
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    
    @State private var players: [Player] = []
    @State private var myRank: Player? = nil
    
    struct Player: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let rank: Int
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("現在のランキング")
                    .font(.headline)
                    .padding(.top, 20)
                    .foregroundColor(Color.textColor)
                
                if players.isEmpty && myRank == nil {
                    Text("ゲームに参加していないよ！")
                        .foregroundColor(Color.textColor)
                        .frame(height: 300)
                } else {
                    VStack {
                        HStack {
                            Text("プレイヤー")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("獲得ポイント")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("ランキング")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.headline)
                        .foregroundStyle(Color.textColor)
                        .padding(.vertical, 8)
                        
                        buildRankingCard()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear {
                loadRanking()
            }
            
            if isShowMenu {
                Color.white.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Menu(router: router)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            BottomNavigationBar(
                router: router,
                isChangeBtn: isChangeBtn,
                onCameraTap: { router.push(.camera) },
                onMenuTap: {
                    isChangeBtn.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private func buildRankingCard() -> some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(players) { player in
                        HStack {
                            Text(player.name)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.title2)
                                .foregroundStyle(Color.textColor)
                            Text("\(player.points)pt")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.title2)
                                .foregroundStyle(Color.textColor)
                            if player.rank <= 3 {
                                RankTextView(text: "\(player.rank)位", rank: player.rank)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                Text("\(player.rank)位")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.title.bold())
                                    .foregroundStyle(Color.textColor)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(height: 420)
            
            if let myRank = myRank,
               !players.contains(where: { $0.name == myRank.name }) {
                Divider()
                    .padding(.vertical, 8)
                HStack {
                    Text("自分")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title2)
                        .foregroundStyle(Color.textColor)
                    Text("\(myRank.points)pt")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title2)
                        .foregroundStyle(Color.textColor)
                    if myRank.rank <= 3 {
                        RankTextView(text: "\(myRank.rank)位", rank: myRank.rank)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("\(myRank.rank)位")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.title.bold())
                            .foregroundStyle(Color.textColor)
                    }
                }
                .padding(.vertical, 16)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
        .frame(maxWidth: 350)
    }
    
    private func loadRanking() {
        print("gameId:", gameId)
        Task {
            do {
                guard let token = getKeyChain(key: "authToken") else {
                    return
                }

                let (ranks, selfRank) = try await RankingService.fetchSoloTop10(gameId: gameId)

                DispatchQueue.main.async {
                    players = ranks.enumerated().map { (index, rank) in
                        Player(name: rank.userName, points: rank.points, rank: index + 1)
                    }
                    myRank = Player(name: selfRank.userName, points: selfRank.point, rank: selfRank.rank)
                }
            } catch {
                print("ランキング読み込みエラー:", error)
            }
        }
    }
}

#Preview {
    SoloRankingView(router: Router())
}
