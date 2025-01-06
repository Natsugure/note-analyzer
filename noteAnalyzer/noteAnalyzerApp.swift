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
    @StateObject var viewModel: ViewModel
    
    init() {
//        UserDefaults.standard.register(defaults: [
//            AppConstants.UserDefaults.lastCalculateAt : "1970/1/1 00:00",
//            AppConstants.UserDefaults.urlname : "（不明なユーザー名）",
//            AppConstants.UserDefaults.contentsCount: 0
//        ])
        
        #if DEBUG
        // UserDefaults内にisDemoModeがsetされていないなら、trueをsetする。
        // ※defaultValueをregister(defaults:)するとバグる可能性があるため。
        if !AppConfig.$isDemoMode.isValueSet {
            AppConfig.isDemoMode = true
        }
        
        if AppConfig.isDemoMode {
            _viewModel = StateObject(wrappedValue: DemoViewModel())
        } else {
            let authManager = AuthenticationManager()
            let networkService = NetworkService(authManager: authManager)
            let realmManager = RealmManager()
            
            _viewModel = StateObject(wrappedValue: ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
        }
        
        #else
        let authManager = AuthenticationManager()
        let networkService = NetworkService(authManager: authManager)
        let realmManager = RealmManager()
        
        _viewModel = StateObject(wrappedValue: ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
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
