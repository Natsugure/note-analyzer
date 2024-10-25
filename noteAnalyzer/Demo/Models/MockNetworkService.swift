//
//  MockNetworkService.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

class MockNetworkService: NetworkServiceProtocol {
    /// 実際のAPIをフェッチする代わりに、URLに基づいた適切なモックデータを返す
    func fetchData(url urlString: String) async throws -> Data {
        if urlString.contains("stats/pv") {
            return createMockStatsData()
        } else if urlString.contains("creators") {
            return createMockContentsData()
        }
        throw NAError.network(.unknownNetworkError(NSError(domain: "", code: -1)))
    }
    
    private func createMockStatsData() -> Data {
        let mockStats = APIStatsResponse(
            data: APIStatsResponse.APIStatsData(
                noteStats: [
                    APIStatsResponse.APIStatsItem(
                        id: 1,
                        name: "サンプル記事1",
                        body: "これはサンプル記事の本文です。",
                        type: .text,
                        readCount: 1200,
                        likeCount: 90,
                        commentCount: 10,
                        user: APIStatsResponse.APIUserInfo(urlname: "demo_user")
                    ),
                    APIStatsResponse.APIStatsItem(
                        id: 2,
                        name: "サンプル記事2",
                        body: "2つ目のサンプル記事です。",
                        type: .text,
                        readCount: 800,
                        likeCount: 30,
                        commentCount: 5,
                        user: APIStatsResponse.APIUserInfo(urlname: "demo_user")
                    ),
                    APIStatsResponse.APIStatsItem(
                        id: 3,
                        name: nil,
                        body: "これはつぶやきのサンプルです。",
                        type: .talk,
                        readCount: 150,
                        likeCount: 15,
                        commentCount: 1,
                        user: APIStatsResponse.APIUserInfo(urlname: "demo_user")
                    )
                ],
                lastPage: true,
                lastCalculateAt: "2024/10/25 12:00"
            )
        )
        
        return try! JSONEncoder().encode(mockStats)
    }
    
    private func createMockContentsData() -> Data {
        let mockContents = APIContentsResponse(
            data: APIContentsResponse.APIContentsData(
                contents: [
                    APIContentsResponse.APIContentItem(
                        id: 1,
                        publishAt: "2024-10-20T12:00:00+09:00"
                    ),
                    APIContentsResponse.APIContentItem(
                        id: 2,
                        publishAt: "2024-10-22T15:00:00+09:00"
                    ),
                    APIContentsResponse.APIContentItem(
                        id: 3,
                        publishAt: "2024/10/24T19:00:00+09:00"
                    )
                ],
                isLastPage: true
            )
        )
        
        return try! JSONEncoder().encode(mockContents)
    }
    
    func resetWebComponents() {
        // デモ用なので何もしない
    }
}
