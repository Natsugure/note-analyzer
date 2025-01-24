//
//  noteAnalyzerApp.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI
import RealmSwift

@main
struct noteAnalyzerApp: SwiftUI.App {
    private let apiClient: NoteAPIClient
    private let authService: AuthenticationServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let realmManager: RealmManager
    
    init() {
#if DEBUG
        // UserDefaults内にisDemoModeがsetされていないなら、trueをsetする。
        // ※defaultValueをregister(defaults:)するとバグる可能性があるため。
        if !AppConfig.$isDemoMode.isSetValue {
            AppConfig.isDemoMode = true
        }
        
        if AppConfig.isDemoMode {
            print("demoMode")

            self.realmManager = RealmManager()
            let provider = MockDataProvider()
            let localItems = realmManager.getItem()
            provider.injectLocalItems(localItems)
            
            self.authService = MockAuthenticationService()
            self.networkService = MockNetworkService(provider: provider)
            self.apiClient = NoteAPIClient(authManager: authService, networkService: networkService)

        } else {
            print("normalMode")
            self.networkService = NetworkService()
            self.authService = AuthenticationService(networkService: networkService)
            self.apiClient = NoteAPIClient(authManager: authService, networkService: networkService)
            self.realmManager = RealmManager()
        }
#else
        self.networkService = NetworkService()
        self.authManager = AuthenticationService(networkService: networkService)
        self.apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
        self.realmManager = RealmManager()
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                authService: authService,
                networkService: networkService,
                apiClient: apiClient,
                realmManager: realmManager
            )
        }
    }
}
