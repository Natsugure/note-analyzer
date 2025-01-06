//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ViewModel
    // TODO: AppStorageをやめて、UserDefaultプロパティラッパーで値を監視できるようにしたほうが良さげ。
    @AppStorage(AppConfig.$isAuthenticationConfigured.key.rawValue) private var isAuthenticationConfigured = false
    
    var body: some View {
        if !isAuthenticationConfigured {
            OnboardingView()
        } else {
            MainView()
        }
    }
}

struct Content_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
