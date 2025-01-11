//
//  AuthWebViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/09.
//

import SwiftUI
import WebKit

class AuthWebViewModel: ObservableObject, WebViewModelProtocol {
    @Published var isPresented = true
    @Published var showLoadingView = false
    @Published var shouldShowInitialSetupView = false
    @Published var error: NAError?
    @Published var urlString: String = AppConstants.URL.authUrl {
        didSet {
            if urlString == AppConstants.URL.topPage {
                Task {
                    await checkAuthentication()
                }
            }
        }
    }
    
    private(set) var webView: WKWebView
    private let authManager: AuthenticationProtocol
    
    init(authManager: AuthenticationProtocol) {
        self.authManager = authManager
        self.webView = WKWebView()
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
    func checkAuthentication() async {
        let allCookies = await WKWebsiteDataStore.default().httpCookieStore.allCookies()
        
        showLoadingView = true
        
        if authManager.isValidAuthCookies(cookies: allCookies) {
            showInitialSetupView()
        } else {
            error = .auth(.authCookiesNotFound)
        }
        
        showLoadingView = false
    }
    
    func showInitialSetupView() {
        shouldShowInitialSetupView = true
        isPresented = false
    }
}
