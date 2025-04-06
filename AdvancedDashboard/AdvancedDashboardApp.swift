//
//  AdvancedDashboardApp.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    let apiClient: NoteAPIClient
    let authService: AuthenticationServiceProtocol
    let networkService: NetworkServiceProtocol
    let realmManager: RealmManager
    
    override init() {
#if DEBUG
        UserDefaultsMigrator.migrateIfNeeded()
        
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
            self.apiClient = MockNoteAPIClient(authManager: authService, networkService: networkService)
            
            super.init()
            
            if localItems.isEmpty {
                generateInitialMockItems(provider: provider)
            }
            
        } else {
            print("normalMode")
            self.networkService = NetworkService()
            self.authService = AuthenticationService(networkService: networkService)
            self.apiClient = NoteAPIClient(authManager: authService, networkService: networkService)
            self.realmManager = RealmManager()
            
            super.init()
        }
#else
        self.networkService = NetworkService()
        self.authService = AuthenticationService(networkService: networkService)
        self.apiClient = NoteAPIClient(authManager: authService, networkService: networkService)
        self.realmManager = RealmManager()
        
        super.init()
#endif
    }
    
    func generateInitialMockItems(provider: MockDataProvider) {
        Task {
            do {
                let initialData = try await provider.generateInitialReviewData()
                
                for item in initialData {
                    let stats = item.value.0
                    let publishedDate = item.value.1
                    
                    try self.realmManager.writeStats(stats: stats, publishedDate: publishedDate, at: item.key)
                }
                 print("initial mock data generated")
            } catch {
                print(error)
            }
        }
    }
}

@main
struct AdvancedDashboardApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                authService: appDelegate.authService,
                networkService: appDelegate.networkService,
                apiClient: appDelegate.apiClient,
                realmManager: appDelegate.realmManager
            )
        }
    }
}


