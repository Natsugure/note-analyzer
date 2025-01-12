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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let apiClient: NoteAPIClient
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    private let realmManager = RealmManager()
    
    init() {
        #if DEBUG
        // UserDefaults内にisDemoModeがsetされていないなら、trueをsetする。
        // ※defaultValueをregister(defaults:)するとバグる可能性があるため。
        if !AppConfig.$isDemoMode.isSetValue {
            AppConfig.isDemoMode = true
        }
        
        if AppConfig.isDemoMode {
            print("demoMode")
            self.authManager = MockAuthenticationManager()
            
            let provider = MockDataProvider()
            let localItems = realmManager.getItem()
            provider.injectLocalItems(localItems)
            
            self.networkService = MockNetworkService(provider: provider)
            
            self.apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
            
        } else {
            print("normalMode")
            self.authManager = AuthenticationManager()
            self.networkService = NetworkService(authManager: authManager)
            self.apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
        }
#else
        self.authManager = AuthenticationManager()
        self.networkService = NetworkService(authManager: authManager)
        self.apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                authManager: authManager,
                networkService: networkService,
                apiClient: apiClient,
                realmManager: realmManager
            )
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        setupRealm()

        return true
    }
    
    
    func setupRealm() {
        // マイグレーションの設定
        let config = Realm.Configuration(
            schemaVersion: 2, // スキーマバージョンをインクリメント
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
                        if let oldPublishedAt = oldObject?["publishedAt"] as? String {
                            let dateFormatter = ISO8601DateFormatter()
                            if let date = dateFormatter.date(from: oldPublishedAt) {
                                newObject?["publishedAt"] = date
                            }
                        }
                    }
                }
            }
        )
        // Realmのデフォルト設定を更新
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
//            print(Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {
            fatalError("Error initializing new realm: \(error)")
        }
        
    }
}
