//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: NoteViewModel
    @AppStorage(K.UserDefaults.authenticationConfigured) private var isAuthenticationConfigured = false
    
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
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
