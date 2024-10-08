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
    @StateObject var viewModel: NoteViewModel
    
    init() {
        let authManager = AuthenticationManager()
        let networkService = NetworkService(authManager: authManager)
        let realmManager = RealmManager()
        
        _viewModel = StateObject(wrappedValue: NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
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

        UserDefaults.standard.register(defaults: ["lastCalculateAt" : "1970/1/1 00:00"])
        UserDefaults.standard.register(defaults: ["urlname" : ""])
        
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
