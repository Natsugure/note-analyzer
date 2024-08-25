//
//  LoginWebView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/08/25.
//

import SwiftUI

struct AuthWebView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                WebView(isPresented: $viewModel.isAuthenticated, viewModel: viewModel, urlString: K.authUrl)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        viewModel.showAuthWebView.toggle()
                    }
                }
            }
            .navigationTitle("noteへログイン")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AuthWebView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        AuthWebView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}

