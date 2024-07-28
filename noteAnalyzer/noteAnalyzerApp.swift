//
//  noteAnalyzerApp.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI
import RealmSwift

@main
struct noteAnalyzerApp: SwiftUI.App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
//        do {
//            _ = try Realm()
//            print(Realm.Configuration.defaultConfiguration.fileURL!)
//        } catch {
//            fatalError("Error initializing new realm: \(error)")
//        }
        
        UserDefaults.standard.register(defaults: ["lastCalculateAt" : "1970/1/1 00:00"])
        UserDefaults.standard.register(defaults: ["urlname" : ""])
        
        return true
    }
}
