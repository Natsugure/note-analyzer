//
//  LoginWebView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/25.
//

import SwiftUI

struct AuthWebView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
//                WebView(urlString: AppConstants.URL.authUrl, viewModel: viewModel, isPresented: $viewModel.isAuthenticated)
                WebView(urlString: AppConstants.URL.authUrl) { cookies in
                    self.viewModel.checkAuthentication(cookies: cookies)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        viewModel.showAuthWebView = false
                    }
                }
            }
            .navigationTitle("noteへログイン")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//struct AuthWebView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    
//    static var previews: some View {
//        AuthWebView()
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}

