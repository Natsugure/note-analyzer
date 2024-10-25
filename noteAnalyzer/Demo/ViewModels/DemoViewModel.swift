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
}
