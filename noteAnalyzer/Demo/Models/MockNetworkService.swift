//
//  MockNetworkService.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

protocol MockableNetworkServiceProtocol: NetworkServiceProtocol {
    func updateMockItems()
}

class MockNetworkService: MockableNetworkServiceProtocol {
    enum MockResponseType {
        case success
        case error
        case network
    }

    /// モックの動作をコントロールするためのプロパティ
    var responseType: MockResponseType = .success
    
    private var mockDataProvider: MockDataProvider
    
    init(realmItems: [Item]) {
        self.mockDataProvider = MockDataProvider(realmItems: realmItems)
        mockDataProvider.updateLastCalculatedAt()
    }
    
    /// 実際のAPIをフェッチする代わりに、URLに基づいた適切なモックデータを返す
    func fetchData(url urlString: String) async throws -> Data {
        let page = extractPageNumber(from: urlString)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if urlString.contains("stats/pv") {
            return await mockDataProvider.createMockStatsData(page: page)
        } else if urlString.contains("contents?kind=note") {
            return await mockDataProvider.createMockContentsData(page: page)
        } else if urlString.contains("creators") {
            switch responseType {
            case .success:
                return await mockDataProvider.createMockContentsCountData(isSuccess: true)
            case .error:
                return await mockDataProvider.createMockContentsCountData(isSuccess: false)
            case .network:
                throw NAError.network(.unknownNetworkError(NSError(domain: "", code: -1)))
            }
        }
        throw NAError.network(.unknownNetworkError(NSError(domain: "", code: -1)))
    }
    
    func resetWebComponents() {
        // デモ用なので何もしない
    }
    
    /// URLからページ番号を抽出する。
    ///
    /// 例: "page=2" というクエリパラメータがある場合は2を返す。
    /// pageクエリパラメータがない場合は1を返す。
    private func extractPageNumber(from url: String) -> Int {
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let pageItem = queryItems.first(where: { $0.name == "page" }),
              let page = Int(pageItem.value ?? "") else {
            return 1
        }
        return page
    }
//    
//    func injectExistingItems(realmItems: [Item]) {
//        mockDataProvider.appendExistingItems(realmItems: realmItems)
//    }
    
    func updateMockItems() {
        mockDataProvider.updateLastCalculatedAt()
        mockDataProvider.updateExistingItems()
    }
}
