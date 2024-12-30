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
    
    private var mockDataProvider = MockDataProvider()
    
    init() {
        mockDataProvider.updateLastCalculatedAt()
    }
    
    /// 実際のAPIをフェッチする代わりに、URLに基づいた適切なモックデータを返す
    func fetchData(url urlString: String) async throws -> Data {
        let page = extractPageNumber(from: urlString)
        
        if urlString.contains("stats/pv") {
            return mockDataProvider.createMockStatsData(page: page)
        } else if urlString.contains("contents?kind=note") {
            return mockDataProvider.createMockContentsData(page: page)
        } else if urlString.contains("creators") {
            switch responseType {
            case .success:
                return mockDataProvider.createMockContentsCountData(isSuccess: true)
            case .error:
                return mockDataProvider.createMockContentsCountData(isSuccess: false)
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
    /// クエリパラメータがない場合は1を返す。
    private func extractPageNumber(from url: String) -> Int {
        if let pageStr = url.components(separatedBy: "page=").last,
           let page = Int(pageStr) {
            return page
        }
        return 1
    }
    
    func updateMockItems() {
        mockDataProvider.updateLastCalculatedAt()
        mockDataProvider.updateExistingItems()
    }
}
