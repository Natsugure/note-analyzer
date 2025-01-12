//
//  NoteAPIFetcher.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/06.
//

import Foundation

class NoteAPIClient {
    @Published private(set) var progressValue: Double = 0.0
    private var articleCount: Int = 0
    
    private let authManager: AuthenticationProtocol
    let networkService: NetworkServiceProtocol
    private let transformer = NoteDataTransformer()
    
    private let timeIntervalSec: Double = 0.5
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol) {
        self.authManager = authManager
        self.networkService = networkService
    }
    
    func requestFetch() async throws -> ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem]) {
        await resetProgressValue()
        
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
    
    private func resetProgressValue() async {
        await MainActor.run {
            progressValue = 0.0
        }
    }
    
    private func fetchUrlName() async throws -> String {
        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
        let results: APIStatsResponse = try await transformer.parseStatsJSON(networkService.fetchData(url: urlString))
        
        let urlName = results.data.noteStats[0].user.urlname
        
        return urlName
    }
    
    private func fetchArticleCount() async throws -> Int {
        let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)"
        let fetchedData = try await networkService.fetchData(url: urlString)
        
        let parsedResult = try transformer.parseUserDetailJSON(fetchedData)
        
        switch parsedResult.data {
        case .success(let userData):
            return userData.noteCount
            
        case .error(let message):
            throw NAError.decoding(.userNotFound(message))
        }
        
//        switch parsedResult {
//        case .success(let noteCount):
//            return noteCount
//            
//        case .failure(let error):
//            throw error
//            switch error {
//            case NAError.decoding(.userNotFound(_)):
//                // TODO: ここでゼロを返すことは適切か？設計自体考え直したほうがいいのでは？
//                return 0
//            default:
//                throw error
//            }
//        }
    }
        
//    private func parseUserDetailJSON(_ data: Data) -> Result<Int, Error> {
//        do {
//            let results = try transformer.parseUserDetailJSON(data)
//            
//            switch results.data {
//            case .success(let userData):
//                return .success(userData.noteCount)
//                
//            case .error(let message):
//                return .failure(NAError.decoding(.userNotFound(message)))
//            }
//        } catch {
//            return .failure(error)
//        }
//    }
    
    private func fetchStats() async throws -> [APIStatsResponse.APIStatsItem] {
        // TODO: 総ページ数がわかってるなら、maxLoopCountはいらないのでは？クールダウンタイムは要検討だが。
//        let maxLoopCount = 300
        let articlePerPage = 10
        // 総記事数をページあたりの記事数で割り、余りを切り上げて取得ページ数とする
        let totalPageCount = Int(ceil(Double(articleCount) / Double(articlePerPage)))
        
        var responses: [APIStatsResponse] = []
        
        for page in 1...totalPageCount {
            await MainActor.run {
                // ダッシュボートの取得は前半50%分なので、進捗数値は半分にする
                self.progressValue = Double(page) / Double(totalPageCount) * 0.5
            }
            
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            let result = try await transformer.parseStatsJSON(networkService.fetchData(url: urlString))
            
            let thisTimeLastCalculateAt = self.stringToDate(result.data.lastCalculateAt)
            
            if page == 1 && !isUpdated(thisTimeLastCalculateAt) {
                throw NAError.network(.statsNotUpdated)
            }
                
            responses.append(result)
            
            try await Task.sleep(for: .seconds(timeIntervalSec))
        }
        
        AppConfig.lastCalculateAt = responses[0].data.lastCalculateAt
        
        return responses.flatMap(\.data.noteStats)
    }
    
    private func fetchPublishedDate() async throws -> [APIContentsResponse.APIContentItem] {
//        let maxLoopCount = 600
        let articlePerPage = 5
        
        let totalPageCount = Int(ceil(Double(articleCount) / Double(articlePerPage)))
        
        var responses: [APIContentsResponse] = []
        
        for page in 1...totalPageCount {
            await MainActor.run {
                let progress = Double(page) / Double(totalPageCount)
                progressValue = 0.5 + (progress * 0.5)  // 50%から始めて、残りの50%を進める
            }
            
            let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)/contents?kind=note&page=\(page)"
            let result = try await transformer.parseContentsJSON(networkService.fetchData(url: urlString))
            
            responses.append(result)
            
            // リクエスト間に0.5秒の遅延を追加
            try await Task.sleep(for: .seconds(timeIntervalSec))
        }
        
        return responses.flatMap(\.data.contents)
    }
    
    private func isUpdated(_ thisTime: Date) -> Bool {
        // TODO: UserDefaultsに保存する時点では、Date型のほうが楽じゃない？
        let lastTime = self.stringToDate(AppConfig.lastCalculateAt)
        
        return thisTime > lastTime
    }
    
    private func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
    
    func deleteAllComponents() throws {
        try authManager.clearAuthentication()
        networkService.resetWebComponents()
    }
}
