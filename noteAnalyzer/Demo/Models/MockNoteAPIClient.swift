//
//  MockAPIClient.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/12.
//

import Foundation

class MockNoteAPIClient: NoteAPIClient {
    override func requestFetch() async throws -> ([APIStatsResponse.APIStatsItem], [APIContentsResponse.APIContentItem]) {
        let result = try await super.requestFetch()
        
        if let mockNetworkService = networkService as? MockNetworkService {
            mockNetworkService.updateMockItems()
        }
        
        return result
    }
}
