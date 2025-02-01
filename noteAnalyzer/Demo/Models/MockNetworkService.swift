//
//  MockNetworkService.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

//protocol MockableNetworkServiceProtocol: NetworkServiceProtocol {
//    func updateMockItems()
//}

struct MockNetworkService: NetworkServiceProtocol {
    enum MockResponseType {
        case success
        case error
        case network
    }

    /// モックの動作をコントロールするためのプロパティ
    private var responseType: MockResponseType = .success
    /// ネットワークの遅延を再現するための時間。
    private let networkDelaySec: Double = 0.1
    
    private let mockDataProvider: MockDataProvider
    
    init(provider: MockDataProvider) {
        self.mockDataProvider = provider
    }
    
    /// 実際のAPIをフェッチする代わりに、URLに基づいた適切なモックデータを返す
    func fetchData(url urlString: String, cookies: [HTTPCookie]) async throws -> Data {
        let page = extractPageNumber(from: urlString)
        
        try await Task.sleep(for: .seconds(networkDelaySec))
        
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
    
    func resetWebComponents() {}
    
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
    
    func updateMockItems() {
        mockDataProvider.updateDataInProvider()
    }
}
