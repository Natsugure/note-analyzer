//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    @State private var isLoading: Bool = true
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authManager = authManager
        self.networkService = networkService
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    var body: some View {
        ZStack {
            MainTabView(authManager: authManager, apiClient: apiClient, realmManager: realmManager)
                .zIndex(1)
            
            if isLoading {
                // TODO: ただの四角形ではなく、いい感じのロゴを表示する
                Rectangle()
                    .fill(Color.white)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation {
                isLoading = false
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
