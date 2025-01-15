//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
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
        VStack {
            // TODO: フラグを使ったif文ではなく、MainViewの上にOnboardingViewをfullScreenCoveredなモーダル表示にする
            if !isAuthenticationConfigured {
                OnboardingView(viewModel: OnboardingViewModel(authManager: authManager, apiClient: apiClient, realmManager: realmManager))
            } else {
                MainView(apiClient: apiClient, realmManager: realmManager)
            }
        }
    }
}

struct Content_Previews: PreviewProvider {
    static let authManager = MockAuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let apiClient = MockNoteAPIClient(authManager: authManager, networkService: networkService)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        ContentView(authManager: authManager, networkService: networkService, apiClient: apiClient, realmManager: realmManager)
    }
}
