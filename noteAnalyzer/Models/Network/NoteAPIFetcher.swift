//
//  NoteAPIFetcher.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/06.
//

import Foundation

class NoteAPIFetcher {
    @Published var progressValue: Double = 0.0
    
    private var articleCount: Int = 0
    private let networkService: NetworkServiceProtocol
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getStats() async throws -> ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem]){
        AppConfig.urlname = try await fetchUrlName()
        articleCount = try await fetchArticleCount()
        
        if articleCount == 0 {
            throw NAError.decoding(.notContents)
        }
        
        let statsResults = try await fetchStats()
        let publishedDateResults = try await fetchPublishedDate()
        
        print("取得完了, 総アイテム数: \(statsResults.count)")
        
        return (statsResults, publishedDateResults)
    }
    
    private func fetchArticleCount() async throws -> Int {
        let urlName = try await fetchUrlName()
        
        let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)"
        let fetchedData = try await networkService.fetchData(url: urlString)
        
        let parsedResult = parseUserDetailJSON(data: fetchedData)
        
        switch parsedResult {
        case .success(let noteCount):
            return noteCount
            
        case .failure(let error):
            switch error {
            case NAError.decoding(.userNotFound(_)):
                // TODO: ここでゼロを返すことは適切か？設計自体考え直したほうがいいのでは？
                return 0
            default:
                throw error
            }
        }
    }
    
    private func fetchUrlName() async throws -> String {
        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
        
        let fetchedData = try await networkService.fetchData(url: urlString)
        let results: APIStatsResponse = try decodeAPIResponse(fetchedData)
        
        let urlName = results.data.noteStats[0].user.urlname
        
        return urlName
    }
    
    private func parseUserDetailJSON(data: Data) -> Result<Int, Error> {
        do {
            let results = try decoder.decode(APIResponse<APIUserDetailResponse>.self, from: data)
            
            switch results.data {
            case .success(let userData):
                return .success(userData.noteCount)
                
            case .error(let message):
                return .failure(NAError.decoding(.userNotFound(message)))
            }
        } catch {
            return .failure(error)
        }
    }
    
    private func fetchStats() async throws -> [APIStatsResponse.APIStatsItem] {
        // TODO: 総ページ数がわかってるなら、maxLoopCountはいらないのでは？クールダウンタイムは要検討だが。
        let maxLoopCount = 300
        let articlePerPage = 10
        // 総記事数をページあたりの記事数で割り、余りを切り上げて取得ページ数とする
        let totalPageCount = Int(ceil(Double(articleCount) / Double(articlePerPage)))
        
//        var statsItems: [APIStatsResponse.APIStatsItem] = []
        var responses: [APIStatsResponse] = []
        
        for page in 1...totalPageCount {
            await MainActor.run {
                // ダッシュボートの取得は前半50%分なので、進捗数値は半分にする
                self.progressValue = Double(page) / Double(totalPageCount) * 0.5
            }
            
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            let result = try await parseStatsJSON(networkService.fetchData(url: urlString))
            
            let thisTimeLastCalculateAt = self.stringToDate(result.data.lastCalculateAt)
            
            if page == 1 && !isUpdated(thisTimeLastCalculateAt) {
                throw NAError.network(.statsNotUpdated)
            }
                
            responses.append(result)
        }
        
        AppConfig.lastCalculateAt = responses[0].data.lastCalculateAt
        
        return responses.flatMap(\.data.noteStats)
    }
    
    private func parseStatsJSON(_ data: Data) async throws -> APIStatsResponse {
        let results: APIStatsResponse = try decodeAPIResponse(data)
        
        return results
//        
//        await MainActor.run {
//            let thisTime = self.stringToDate(results.data.lastCalculateAt)
//            let lastTime = self.stringToDate(AppConfig.lastCalculateAt)
//            
//            // lastCalculateAtがUserDefaultsに保存されている値よりも古い場合、更新されていないと判断
//            if thisTime <= lastTime {
//                throw NAError.network(.statsNotUpdated)
//            } else {
//                self.contents += results.data.noteStats
//                
//                if self.isLastPage {
//                    AppConfig.lastCalculateAt = results.data.lastCalculateAt
//                    
//                    AppConfig.contentsCount = self.contents.count
//                    self.contentsCount = self.contents.count
//                }
//            }
//        }
    }
    
    private func fetchPublishedDate() async throws -> [APIContentsResponse.APIContentItem] {
        let maxLoopCount = 600
        let articlePerPage = 5
        
        let totalPageCount = Int(ceil(Double(articleCount) / Double(articlePerPage)))
        
        var responses: [APIContentsResponse] = []
        
        for page in 1...totalPageCount {
            await MainActor.run {
                let progress = Double(page) / Double(totalPageCount)
                progressValue = 0.5 + (progress * 0.5)  // 50%から始めて、残りの50%を進める
            }
            
            let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)/contents?kind=note&page=\(page)"
            let result = try await parseContentsJSON(networkService.fetchData(url: urlString))
            
            responses.append(result)
            
            // リクエスト間に0.5秒の遅延を追加
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return responses.flatMap(\.data.contents)
    }
    
    private func parseContentsJSON(_ data: Data) throws -> APIContentsResponse {
        let results: APIContentsResponse = try decodeAPIResponse(data)
        
        return results
    }
    
    private func isUpdated(_ thisTime: Date) -> Bool {
        // TODO: UserDefaultsに保存する時点では、Date型のほうが楽じゃない？
        let lastTime = self.stringToDate(AppConfig.lastCalculateAt)
        
        return thisTime <= lastTime
    }
    
    private func decodeAPIResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            // まず、APIStatsResponseとしてデコードを試みる
            return try decoder.decode(T.self, from: data)
        } catch {
            // デコードに失敗した場合、エラーレスポンスとしてデコードを試みる
            do {
                let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                if errorResponse.error.code == "auth" {
                    throw NAError.auth(.authenticationFailed)
                } else {
                    throw NAError.decoding(.decodingFailed(error))
                }
            } catch {
                // エラーレスポンスのデコードにも失敗した場合
                throw error
            }
        }
    }
    
    private func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
}
