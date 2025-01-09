//
//  DemoViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

class DemoViewModel: ViewModel {
    private let mockNetworkService: MockableNetworkServiceProtocol
    
    init() {
        let mockAuthManager = MockAuthenticationManager()
        let realmManager = RealmManager()
        
        let mockNetworkService = MockNetworkService(realmItems: realmManager.getItemArray())
        self.mockNetworkService = mockNetworkService
        let apiFetcher = NoteAPIFetcher(networkService: mockNetworkService)
        
        super.init(
            authManager: mockAuthManager,
            networkService: mockNetworkService,
            realmManager: realmManager,
            apiFetcher: apiFetcher
        )
        
        print("DemoViewModel initialized")
    }
    
    override func getStats() async throws {
        try await super.getStats()
        
        mockNetworkService.updateMockItems()
    }
    
    override func clearAllData() async throws {
        try await MainActor.run {
            try realmManager.deleteAll()
            AppConfig.deleteUserInfo()
        }
    }
}
