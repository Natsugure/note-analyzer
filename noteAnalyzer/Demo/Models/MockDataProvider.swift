//
//  MockDataProvider.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/12/30.
//

import Foundation
import RealmSwift

class MockDataProvider {
    private var lastCalculatedAt: Date
    private var mockItems: [MockItem] = []
    private var currentNoteCount = 0
    private var mockUserId = 12345
    
    private let transformer = NoteDataTransformer()
    
    // モックデータの1アイテムを表す構造体
    private struct MockItem {
        let id: Int
        let name: String?
        let body: String
        let type: ContentType
        var readCount: Int
        var likeCount: Int
        var commentCount: Int
        let publishAt: String
    }
    
    init() {
        let date = Date()
        // 即時更新できるように、イニシャライズした1時間前に設定
        lastCalculatedAt = Calendar.current.date(byAdding: .hour, value: -1, to: date)!
    }
    
    /// デバイス内のデータをmockItemに変換し、サーバー(MockDataProvider)も同じ記事データを持っているようにする
    func injectLocalItems(_ realmItems: Results<Item>) {
        mockItems += convertToMockItems(from: realmItems)
        
        currentNoteCount = mockItems.count
        
        if currentNoteCount == 0 {
            
        } else {
            updateExistingItems()
            generateNewMockItems()
        }
        updateLastCalculatedAt()
    }
    
    func generateInitialReviewData() async throws ->
    [Date: ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem])]{
        let calendar = Calendar.current
        let today = Date()
        // 30日前からスタート
        var currentDate = calendar.date(byAdding: .day, value: -30, to: today)!
        
        var reviewData: [Date: ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem])] = [:]
        
        // 初日は2-3記事
        let initialItemCount = Int.random(in: 2...3)
        for _ in 0..<initialItemCount {
            let newItem = generateMockItem(publishedAt: currentDate)
            
            mockItems.append(newItem)
        }
        
        reviewData[currentDate] = try await createDayResult()
        updateExistingItems()
        
        for dayOffset in stride(from: 29, through: 1, by: -1) {
            currentDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            print("currentDate in \(dayOffset): \(currentDate)")
            
            generateNewMockItems(date: currentDate)
            
            reviewData[currentDate] = try await createDayResult()
            updateExistingItems()
        }
        
        updateDataInProvider()
        
        return reviewData
    }
    
    private func createDayResult() async throws -> ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem]) {
        var statsResults: [APIStatsResponse.APIStatsItem] = []
        var contentsResults: [APIContentsResponse.APIContentItem] =  []
        
        let statsPageCount = Int(ceil(Double(currentNoteCount) / Double(10)))
        let contentPageCount = Int(ceil(Double(currentNoteCount) / Double(5)))
        
        for i in 1...statsPageCount {
            let stats: APIStatsResponse = try await transformer.decodeAPIResponse(createMockStatsData(page: i))
            
            statsResults += stats.data.noteStats
        }
        
        for i in 1...contentPageCount {
            let contents: APIContentsResponse = try await transformer.decodeAPIResponse(createMockContentsData(page: i))
            
            contentsResults += contents.data.contents
        }
        
        return (statsResults, contentsResults)
    }
    
    private func convertToMockItems(from realmItems: Results<Item>) -> [MockItem] {
        var result: [MockItem] = []
        
        for item in realmItems {
            let latestStats = item.stats.max(by: { $0.updatedAt < $1.updatedAt })!
            
            let mockItem = MockItem(
                id: item.id,
                name: item.type == .text ? item.title : nil,
                body: item.type == .talk ? item.title : "",
                type: item.type,
                readCount: latestStats.readCount,
                likeCount: latestStats.likeCount,
                commentCount: latestStats.commentCount,
                publishAt: self.dateToString2(date: item.publishedAt)
                )
            
            result.append(mockItem)
        }
        
        return result
    }
    
    func generateNewMockItems(date: Date = Date()) {
        let newItemCount = Int.random(in: 1...3)
        for i in 0..<newItemCount {
            let publishedAt = Calendar.current.date(byAdding: .hour, value: i, to: date)!
            
            let newItem = generateMockItem(publishedAt: publishedAt)
            
            mockItems.append(newItem)
        }
    }
    
    func updateDataInProvider() {
        updateExistingItems()
        generateNewMockItems()
        updateLastCalculatedAt()
    }
    
    private func generateMockItem(publishedAt: Date = Date()) -> MockItem {
        currentNoteCount += 1
        
        let type: ContentType = ContentType.weightedRandomElement()
        let readCount = Int.random(in: 100...500)
        let likeCount = Int(Double(readCount) * Double.random(in: 0.05...0.2))
        let commentCout = Int.random(in: 0...2)
        
        let newItem = MockItem(
            id: currentNoteCount,
            name: type == .talk ? nil : "サンプル\(type.name)\(currentNoteCount)",
            body: "これは全記事通算\(currentNoteCount)番目の\(type.name)です",
            type: type,
            readCount: readCount,
            likeCount: likeCount,
            commentCount: commentCout,
            publishAt: dateToString2(date: publishedAt)
        )
        
        return newItem
    }
    
    func createMockStatsData(page: Int) async -> Data {
        let startIndex = (page - 1) * 10
        let endIndex = min(startIndex + 10, mockItems.count)
        let pageItems = Array(mockItems[startIndex..<endIndex])
        
        let mockStats = APIStatsResponse(
            data: APIStatsResponse.APIStatsData(
                noteStats: pageItems.map { item in
                    APIStatsResponse.APIStatsItem(
                        id: item.id,
                        name: item.name,
                        body: item.body,
                        type: item.type,
                        readCount: item.readCount,
                        likeCount: item.likeCount,
                        commentCount: item.commentCount,
                        user: APIStatsResponse.APIUserInfo(urlname: "demo_user")
                    )
                },
                lastPage: endIndex >= mockItems.count,
                lastCalculateAt: dateToString(date: lastCalculatedAt)
            )
        )
        
        return try! JSONEncoder().encode(mockStats)
    }
    
    func createMockContentsCountData(isSuccess: Bool) async -> Data {
        let mockData = isSuccess
        ? APIResponse<APIUserDetailResponse>(data: .success(APIUserDetailResponse(id: mockUserId, noteCount: currentNoteCount)))
            : APIResponse<APIUserDetailResponse>(data: .error("リソースが見つかりません"))
        
        return try! JSONEncoder().encode(mockData)
    }
    
    func createMockContentsData(page: Int = 1) async -> Data {
        let startIndex = (page - 1) * 5
        let endIndex = min(startIndex + 5, mockItems.count)
        let pageItems = Array(mockItems[startIndex..<endIndex])
        
        let mockContents = APIContentsResponse(
            data: APIContentsResponse.APIContentsData(
                contents: pageItems.map { item in
                    APIContentsResponse.APIContentItem(
                        id: item.id,
                        publishAt: item.publishAt
                    )
                },
                isLastPage: endIndex >= mockItems.count
            )
        )
        
        return try! JSONEncoder().encode(mockContents)
    }
    
    /// モックデータ用の`lastCalculatedAt`を、今回更新分から1分進める。こうすることで、更新ボタンをまたすぐに押してもデータの取得ができる。
    private func updateLastCalculatedAt() {
        lastCalculatedAt = Calendar.current.date(byAdding: .minute, value: 1, to: lastCalculatedAt)!
    }
    
    /// 既存のモックデータの統計ステータスを増加させる
    private func updateExistingItems() {
        for i in 0..<mockItems.count {
            let increasementReadCount = Int.random(in: 10...50)
            
            mockItems[i].readCount += increasementReadCount
            mockItems[i].likeCount += Int(Double(increasementReadCount) * Double.random(in: 0.05...0.1))
            // コメントはめったに増えないので、95%の確率で増加分を0にする
            mockItems[i].commentCount += Double.random(in: 0...1) < 0.95 ? 0 : 1
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: date)
    }
    
    private func dateToString2(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: date)
    }
}
