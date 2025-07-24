//import SwiftUI
//
//struct SoloRankingView: View {
//    struct Player: Identifiable {
//        let id = UUID()
//        let name: String
//        let points: Int
//        let rank: Int
//    }
//
//    @State private var players: [Player] = []
//
//    var body: some View {
//        ZStack {
//            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 16) {
//                Text("現在のランキング")
//                    .font(.headline)
//                    .padding(.top, 20)
//
//                if players.isEmpty {
//                    ProgressView("読み込み中…")
//                        .padding()
//                } else {
//                    buildRankingCard()
//                }
//
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//            .onAppear {
//                RankingService.fetchTop10 { topList in
//                    self.players = topList.enumerated().map { idx, item in
//                        Player(name: item.UserId, points: item.Points, rank: idx + 1)
//                    }
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func buildRankingCard() -> some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("プレイヤー")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text("獲得ポイント")
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Text("ランキング")
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//            .font(.subheadline)
//            .foregroundColor(.gray)
//            .padding(.vertical, 8)
//
//            Divider()
//
//            ForEach(players) { player in
//                HStack {
//                    Text(player.name)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Text("\(player.points)pt")
//                        .frame(maxWidth: .infinity, alignment: .center)
//                    Text("\(player.rank)位")
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .rankColor(rank: player.rank)
//                }
//                .padding(.vertical, 12)
//
//                if player.id != players.last?.id {
//                    Divider()
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//    }
//}
//
//fileprivate extension View {
//    func rankColor(rank: Int) -> some View {
//        switch rank {
//        case 1: return self.foregroundColor(.yellow)
//        case 2: return self.foregroundColor(.gray)
//        case 3: return self.foregroundColor(.orange)
//        default: return self.foregroundColor(.brown)
//        }
//    }
//}
//
//
import SwiftUI

struct SoloRankingView: View {
    // ルーティング（画面遷移など）に使用
    @ObservedObject var router: Router
    // メニュー表示状態
    @State private var isChangeBtn = false
    @State private var isShowMenu = false
    
    // 外部から渡されるID
    private let userId: String
    private let gameId: String
    
    @State private var players: [Player] = []
    @State private var myRank: Player? = nil       // 自分の順位（APIに含まれていれば）
    
    // プレイヤー情報（ランキング表示用）（できれば違うファイルに分けて欲しい）
    struct Player: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let rank: Int
    }
    
    
    /// イニシャライザで userId, gameId を受け取る
    init(router: Router,userId: String, gameId: String) {
        self.router = router
        self.userId = userId
        self.gameId = gameId
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("現在のランキング")
                    .font(.headline)
                    .padding(.top, 20)
                
                if players.isEmpty && myRank == nil {
                    // ランキングデータがない（ゲーム未参加）
                    Text("ゲームに参加していないよ！")
                        .foregroundColor(.gray)
                        .frame(height: 300) // 固定サイズ（例）
                } else {
                    VStack{
                        // ヘッダー
                        HStack {
                            Text("プレイヤー")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("獲得ポイント")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("ランキング")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.textColor)
                        .padding(.vertical, 8)
                        
                        // ランキングカード
                        buildRankingCard()
                    }
                    
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            // ランキングデータの取得
            .onAppear {
                mockLoadRanking()
            }
            
            
            // ナビゲーションバーの処理
            if isShowMenu {
                Color.white.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Menu(router: router)
                    .transition(
                        .move(edge: .trailing)
                        .combined(with: .opacity)
                    )
            }
            
            
            BottomNavigationBar(
                router: router,
                isChangeBtn: isChangeBtn,
                onCameraTap: {
                    router.push(.camera)
                },
                onMenuTap: {
                    //   ボタンの見た目切り替えは即時（アニメなし）
                    isChangeBtn.toggle()
                    
                    //　　メニュー本体の表示はアニメーション付き
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowMenu.toggle()
                    }
                }
            )
        }
    }
    
    // MARK: - ランキング表示カード
    @ViewBuilder
    private func buildRankingCard() -> some View {
        
        VStack{
            // スクロールビューで7人分の高さに固定
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(players) { player in
                        HStack {
                            Text(player.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .foregroundStyle(Color.textColor)
                            Text("\(player.points)pt")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.title2)
                                .foregroundStyle(Color.textColor)
                            Text("\(player.rank)位")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .font(.title.bold())
                                .rankColor(rank: player.rank)
                            
                        }
                        .padding(.vertical, 16)
                        
                        if player.id != players.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(height: 420)
            // 自分の順位を最後に表示（playersに含まれていない場合）
            if let myRank = myRank,
               !players.contains(where: { $0.name == myRank.name }) {
                Divider()
                    .padding(.vertical, 8)
                
                HStack {
                    Text("自分")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .foregroundStyle(Color.textColor)
                    Text("\(myRank.points)pt")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title2)
                        .foregroundStyle(Color.textColor)
                    Text("\(myRank.rank)位")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.title.bold())
                        .rankColor(rank: myRank.rank)
                }
                .padding(.vertical, 16)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    //            // プレイヤーごと行表示
    //            ForEach(players) { player in
    //                HStack {
    //                    Text(player.name)
    //                        .frame(maxWidth: .infinity, alignment: .leading)
    //                    Text("\(player.points)pt")
    //                        .frame(maxWidth: .infinity, alignment: .center)
    //                    Text("\(player.rank)位")
    //                        .frame(maxWidth: .infinity, alignment: .trailing)
    //                        .rankColor(rank: player.rank)
    //                }
    //                .padding(.vertical, 12)
    //
    //                // 最後以外に区切り線
    //                if player.id != players.last?.id {
    //                    Divider()
    //                }
    //            }
    //        }
    //        .padding()
    //        .background(Color.white)
    //        .cornerRadius(12)
    //        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    //    }
    
//    // MARK: - ランキング取得処理
//    private func loadRanking() {
//        RankingService.fetchTop10(userId: userId, gameId: gameId) { topRankings in
//            // UI更新はメインスレッドで
//            DispatchQueue.main.async {
//                players = topRankings.enumerated().map { index, top in
//                    Player(name: top.UserId,
//                           points: top.Points,
//                           rank: index + 1)
//                }
//            }
//        }
//    }
    private func mockLoadRanking() {
        let samplePlayers = (1...15).map { i in
            Player(name: "User\(i)", points: 1500 - i * 30, rank: i)
        }
        self.players = samplePlayers.filter { $0.name != "User12" }
        self.myRank = Player(name: "User12", points: 1170, rank: 12)
    }
}

// MARK: - ランクに応じた色付け
fileprivate extension View {
    func rankColor(rank: Int) -> some View {
        switch rank {
        case 1: return self.foregroundColor(.yellow)
        case 2: return self.foregroundColor(.gray)
        case 3: return self.foregroundColor(.orange)
        default: return self.foregroundColor(Color.textColor)
        }
    }
}

#Preview {
    SoloRankingView(router: Router(),
                    userId: "userid-50452766-49e8-4dd9-84a1-d02ee1c2425c",
                    gameId: "gameid-8a5fafff-0b2e-4f2b-b011-da21a5a724cd")
}
