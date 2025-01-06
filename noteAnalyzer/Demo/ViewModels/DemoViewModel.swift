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
        
        super.init(
            authManager: mockAuthManager,
            networkService: mockNetworkService,
            realmManager: realmManager
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
            
            UserDefaults.standard.set("1970/1/1 00:00", forKey: AppConstants.UserDefaults.lastCalculateAt)
            UserDefaults.standard.set("不明なユーザー名", forKey: AppConstants.UserDefaults.urlname)
        }
    }
}
