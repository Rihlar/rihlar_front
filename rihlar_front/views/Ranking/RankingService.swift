//import Foundation
//
//struct TopRanking: Codable {
//    let UserId: String
//    let Points: Int
//}
//
//class RankingService {
//    static func fetchTop10(completion: @escaping ([TopRanking]) -> Void) {
//        guard let url = URL(string: "https://rihlar-test.kokomeow.com/gcore/get/top") else {
//            print("URL生成失敗")
//            completion([])
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("userid-50452766-49e8-4dd9-84a1-d02ee1c2425c", forHTTPHeaderField: "UserID")
//        request.setValue("gameid-8a5fafff-0b2e-4f2b-b011-da21a5a724cd", forHTTPHeaderField: "GameID")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("通信エラー:", error)
//                DispatchQueue.main.async { completion([]) }
//                return
//            }
//
//            guard let data = data else {
//                print("データが取得できませんでした")
//                DispatchQueue.main.async { completion([]) }
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode([TopRanking].self, from: data)
//                DispatchQueue.main.async {
//                    completion(decoded)
//                    print(decoded)
//                }
//            } catch {
//                print("デコードエラー:", error)
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("レスポンス内容:", jsonString)
//                }
//                DispatchQueue.main.async {
//                    completion([])
//                }
//            }
//        }.resume()
//    }
//}
import Foundation

struct TopRanking: Codable {
    let UserId: String
    let Points: Int
}

class RankingService {
    /// UserID と GameID をパラメータで受け取るように変更
    static func fetchTop10(userId: String,
                           gameId: String,
                           completion: @escaping ([TopRanking]) -> Void) {
        guard let url = URL(string: "https://rihlar-test.kokomeow.com/gcore/get/top") else {
            print("URL生成失敗")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // ここを固定値から渡された値に変更
        request.setValue(userId, forHTTPHeaderField: "UserID")
        request.setValue(gameId, forHTTPHeaderField: "GameID")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("通信エラー:", error)
                DispatchQueue.main.async { completion([]) }
                return
            }

            guard let data = data else {
                print("データが取得できませんでした")
                DispatchQueue.main.async { completion([]) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode([TopRanking].self, from: data)
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } catch {
                print("デコードエラー:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("レスポンス内容:", jsonString)
                }
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}
