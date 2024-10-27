//
//  DemoViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

class DemoViewModel: ViewModel {
    init() {
        let mockAuthManager = MockAuthenticationManager()
        let mockNetworkService = MockNetworkService()
        let realmManager = RealmManager()
        
        super.init(
            authManager: mockAuthManager,
            networkService: mockNetworkService,
            realmManager: realmManager
        )
        print("DemoViewModel initialized")
    }
    
    override func clearAllData() async throws {
        try await MainActor.run {
            try realmManager.deleteAll()
            
            UserDefaults.standard.set("1970/1/1 00:00", forKey: AppConstants.UserDefaults.lastCalculateAt)
            UserDefaults.standard.set("", forKey: AppConstants.UserDefaults.urlname)

        }
    }
}
