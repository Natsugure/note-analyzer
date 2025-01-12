//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    // TODO: AppStorageをやめて、UserDefaultプロパティラッパーで値を監視できるようにしたほうが良さげ。
    @AppStorage(AppConfig.$isAuthenticationConfigured.key.rawValue) private var isAuthenticationConfigured = false
    
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authManager = authManager
        self.networkService = networkService
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    var body: some View {
        if !isAuthenticationConfigured {
            OnboardingView(viewModel: OnboardingViewModel(authManager: authManager))
        } else {
            MainView()
        }
    }
}

//struct Content_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    
//    static var previews: some View {
//        ContentView()
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}
