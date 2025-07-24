import Foundation

// SoloRank：ランキング上位のユーザーデータ
struct SoloRank: Codable {
    let teamID: String
    let userName: String
    let points: Int

    enum CodingKeys: String, CodingKey {
        case teamID = "TeamID"
        case userName = "UserName"
        case points = "Points"
    }
}

// SoloSelfRank：自分の順位データ
struct SoloSelfRank: Codable {
    let rank: Int
    let point: Int
    let userName: String
    let teamID: String

    enum CodingKeys: String, CodingKey {
        case rank = "rank"
        case point = "point"
        case userName = "UserName"
        case teamID = "TeamID"
    }
}

// APIレスポンスのトップレベル構造体
struct SoloRankingResponse: Codable {
    struct DataClass: Codable {
        let ranks: [SoloRank]
        let myRank: SoloSelfRank
        
        enum CodingKeys: String, CodingKey {
                    case ranks
            case myRank = "self"
                }
    }
    let data: DataClass

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

class RankingService {
    /// アクセストークンでソロランキングTOP10と自分の順位を取得（リフレッシュなし）
    static func fetchSoloTop10(gameId: String) async throws -> (players: [SoloRank], myRank: SoloSelfRank) {
        // アクセストークンを取得（リフレッシュ処理は行わない）
        guard let token = try await TokenManager.shared.getAccessToken() else {
            throw NSError(domain: "RankingService",
                          code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "アクセストークンが存在しません"])
        }

        let url = APIConfig.soloRanking(gameId: gameId)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            throw NSError(domain: "RankingService",
                          code: httpResponse.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode): \(body)"])
        }
        
        let result = try JSONDecoder().decode(SoloRankingResponse.self, from: data)
        
        let myRank = result.data.self
        return (players: result.data.ranks, myRank: result.data.myRank)
    }
}


