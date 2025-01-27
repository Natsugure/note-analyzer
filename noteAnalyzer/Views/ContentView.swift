//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    private let authService: AuthenticationServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(authService: AuthenticationServiceProtocol, networkService: NetworkServiceProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authService = authService
        self.networkService = networkService
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    var body: some View {
        ZStack {
            MainTabView(authService: authService, apiClient: apiClient, realmManager: realmManager)
        }
    }
}

struct Content_Previews: PreviewProvider {
    static let authManager = MockAuthenticationService()
    static let networkService = NetworkService()
    static let apiClient = MockNoteAPIClient(authManager: authManager, networkService: networkService)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        ContentView(authService: authManager, networkService: networkService, apiClient: apiClient, realmManager: realmManager)
    }
}
