//
//  MockDataProvider.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/12/30.
//

import Foundation

class MockDataProvider {
    private var lastCalculatedAt: Date
    private var mockItems: [MockItem] = []
    private var currentNoteCount = 0
    
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
    
    init(realmItems: [Item]) {
        let date = Date()
        // 即時更新できるように、イニシャライズした1時間前に設定
        lastCalculatedAt = Calendar.current.date(byAdding: .hour, value: -1, to: date)!
        
        // デバイス内のデータをmockItemに変換し、サーバー(MockDataProvider)も同じ記事データを持っているようにする
        appendExistingItems(realmItems: realmItems)
    }
    
    func appendExistingItems(realmItems: [Item]) {
        mockItems += realmItemsToMockItems(realmItems: realmItems)
        updateExistingItems()
        
        currentNoteCount = mockItems.count
    }
    
    private func realmItemsToMockItems(realmItems: [Item]) -> [MockItem] {
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
    
    private func generateNewMockItems() {
        let newItemCount = Int.random(in: 1...3)
        for _ in 0..<newItemCount {
            currentNoteCount += 1
            
            let type: ContentType = Bool.random() ? .text : .talk
            let newItem = MockItem(
                id: currentNoteCount,
                name: type == .text ? "サンプル記事\(currentNoteCount)" : nil,
                body: "これは全記事通算\(currentNoteCount)番目の\(type.name)です",
                type: type,
                readCount: Int.random(in: 100...1500),
                likeCount: Int.random(in: 10...100),
                commentCount: Int.random(in: 0...20),
                publishAt: dateToString2(date: Calendar.current.date(byAdding: .minute, value: -70, to: lastCalculatedAt)!)
            )
            
            mockItems.append(newItem)
        }
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
        ? APIResponse<APIUserDetailResponse>(data: .success(APIUserDetailResponse(noteCount: currentNoteCount)))
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
    func updateLastCalculatedAt() {
        lastCalculatedAt = Calendar.current.date(byAdding: .minute, value: 1, to: lastCalculatedAt)!
        generateNewMockItems()
    }
    
    /// 既存のモックデータの統計ステータスを増加させる
    func updateExistingItems() {
        for i in 0..<mockItems.count {
            mockItems[i].readCount += Int.random(in: 10...50)
            mockItems[i].likeCount += Int.random(in: 0...5)
            mockItems[i].commentCount += Int.random(in: 0...2)
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
