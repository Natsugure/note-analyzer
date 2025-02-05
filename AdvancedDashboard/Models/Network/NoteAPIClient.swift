//
//  NoteAPIFetcher.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/06.
//

import Foundation

class NoteAPIClient {
    @Published private(set) var progressValue: Double = 0.0
    private var completedPages: Int = 0
    private var totalPages: Int = 0
    
    private let authService: AuthenticationServiceProtocol
    let networkService: NetworkServiceProtocol
    private let transformer = NoteDataTransformer()
    
    private let timeIntervalSec: Double = 0.5
    
    init(authManager: AuthenticationServiceProtocol, networkService: NetworkServiceProtocol) {
        self.authService = authManager
        self.networkService = networkService
    }
    
    func requestFetch() async throws -> ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem]) {
        await resetProgressValue()
        
        AppConfig.urlname = try await fetchUrlName()
        let articleCount = try await fetchArticleCount()
        
        if articleCount == 0 {
            throw NAError.decoding(.notContents)
        }
        
        // 各タスクの総ページ数を計算。各タスクforループ回数と、進捗割合計算に必要。
        let statsPagesCount = calculateStatsPagesCount(articleCount: articleCount)
        let publishedDatePagesCount = calculatePublishedDatePagesCount(articleCount: articleCount)
        totalPages = statsPagesCount + publishedDatePagesCount
        
        async let statsResults = try await fetchStats(totalPages: statsPagesCount)
        async let publishedDateResults = try await fetchPublishedDate(totalPages: publishedDatePagesCount)
        
        let results = try await (statsResults, publishedDateResults)
        
        print("取得完了, 総アイテム数: \(results.0.count)")
        
        return results
    }
    
    private func calculateStatsPagesCount(articleCount: Int) -> Int {
        let articlePerPage: Int = 10
        
        // 総記事数をページあたりの記事数で割り、余りを切り上げて取得ページ数とする
        return Int(ceil(Double(articleCount) / Double(articlePerPage)))
    }
    
    private func calculatePublishedDatePagesCount(articleCount: Int) -> Int {
        let articlePerPage: Int = 5
        
        // 総記事数をページあたりの記事数で割り、余りを切り上げて取得ページ数とする
        return Int(ceil(Double(articleCount) / Double(articlePerPage)))
    }
    
    @MainActor
    private func resetProgressValue() async {
        progressValue = 0.0
        completedPages = 0
    }
    
    @MainActor
    private func updateProgress() {
        completedPages += 1
        progressValue = Double(completedPages) / Double(totalPages)
    }
    
    private func fetchUrlName() async throws -> String {
        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
        let fetchedData = try await networkService.fetchData(url: urlString, cookies: authService.getCookies())
        let results: APIStatsResponse = try transformer.decodeAPIResponse(fetchedData)
        
        let urlName = results.data.noteStats[0].user.urlname
        
        return urlName
    }
    
    private func fetchArticleCount() async throws -> Int {
        let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)"
        let fetchedData = try await networkService.fetchData(url: urlString, cookies: authService.getCookies())
        
        let parsedResult: APIResponse<APIUserDetailResponse> = try transformer.decodeAPIResponse(fetchedData)
        
        switch parsedResult.data {
        case .success(let userData):
            return userData.noteCount
            
        case .error(let message):
            throw NAError.decoding(.userNotFound(message))
        }
    }
    
    private func fetchStats(totalPages: Int) async throws -> [APIStatsResponse.APIStatsItem] {
        var responses: [APIStatsResponse] = []
        
        for page in 1...totalPages {
            try Task.checkCancellation()
            
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            let fetchedData = try await networkService.fetchData(url: urlString, cookies: authService.getCookies())
            let result: APIStatsResponse = try transformer.decodeAPIResponse(fetchedData)
            
            if page == 1 && !isUpdated(self.stringToDate(result.data.lastCalculateAt)) {
                throw NAError.network(.statsNotUpdated)
            }
                
            responses.append(result)
            
            await updateProgress()
            
            try await Task.sleep(for: .seconds(timeIntervalSec))
        }
        
        AppConfig.lastCalculateAt = responses[0].data.lastCalculateAt
        
        return responses.flatMap(\.data.noteStats)
    }
    
    private func fetchPublishedDate(totalPages: Int) async throws -> [APIContentsResponse.APIContentItem] {
        var responses: [APIContentsResponse] = []
        
        for page in 1...totalPages {
            try Task.checkCancellation()
            
            let urlString = "https://note.com/api/v2/creators/\(AppConfig.urlname)/contents?kind=note&page=\(page)"
            let fetchedData = try await networkService.fetchData(url: urlString, cookies: authService.getCookies())
            let result: APIContentsResponse = try transformer.decodeAPIResponse(fetchedData)
            
            responses.append(result)
            
            await updateProgress()
            
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
        try authService.clearAuthentication()
        networkService.resetWebComponents()
    }
}
