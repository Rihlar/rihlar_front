// ランキングページ　そろ
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
    init(router: Router, userId: String, gameId: String) {
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
                    .foregroundColor(Color.textColor)
                
                if players.isEmpty && myRank == nil {
                    // ランキングデータがない（ゲーム未参加）
                    Text("ゲームに参加していないよ！")
                        .foregroundColor(Color.textColor)
                        .frame(height: 300)
                } else {
                    VStack{
                        // ヘッダー
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
                        
                        // ランキングカード
                        buildRankingCard()
                    }
                    
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            // ランキングデータの取得
            .onAppear {
                loadRanking()
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
            // 自分の順位を最後に表示（playersに含まれていない場合）
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
    

    
    // MARK: - ランキング取得処理
    private func loadRanking() {
        RankingService.fetchTop10(userId: userId, gameId: gameId) { topRankings in
            // UI更新はメインスレッドで
            DispatchQueue.main.async {
                players = topRankings.enumerated().map { index, top in
                    Player(name: top.UserId,
                           points: top.Points,
                           rank: index + 1)
                }
            }
        }
    }
    
}

#Preview {
    SoloRankingView(router: Router(),
                    userId: "userid-50452766-49e8-4dd9-84a1-d02ee1c2425c",
                    gameId: "gameid-8a5fafff-0b2e-4f2b-b011-da21a5a724cd")
}
