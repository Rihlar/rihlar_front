import SwiftUI

struct SoloRankingView: View {
    struct Player: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let rank: Int
    }

    @State private var players: [Player] = []

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                Text("現在のランキング")
                    .font(.headline)
                    .padding(.top, 20)

                if players.isEmpty {
                    ProgressView("読み込み中…")
                        .padding()
                } else {
                    buildRankingCard()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear {
                RankingService.fetchTop10 { topList in
                    self.players = topList.enumerated().map { idx, item in
                        Player(name: item.UserId, points: item.Points, rank: idx + 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func buildRankingCard() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("プレイヤー")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("獲得ポイント")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("ランキング")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.vertical, 8)

            Divider()

            ForEach(players) { player in
                HStack {
                    Text(player.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(player.points)pt")
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("\(player.rank)位")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .rankColor(rank: player.rank)
                }
                .padding(.vertical, 12)

                if player.id != players.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

fileprivate extension View {
    func rankColor(rank: Int) -> some View {
        switch rank {
        case 1: return self.foregroundColor(.yellow)
        case 2: return self.foregroundColor(.gray)
        case 3: return self.foregroundColor(.orange)
        default: return self.foregroundColor(.brown)
        }
    }
}

    
