//
//  OnboardingViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/08.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    @Published var shouldShowInitialSetupView = false
    @Published var isShowAlert = false
    
    private let authManager: AuthenticationProtocol
    
    init(authManager: AuthenticationProtocol) {
        self.authManager = authManager
        
        // AuthenticationManagerの状態をViewModelの状態に反映
        if let authManager = authManager as? AuthenticationManager {
//            authManager.$isAuthenticated.assign(to: &$isAuthenticated)
            authManager.$showAuthWebView.assign(to: &$showAuthWebView)
            print("Normal ViewModel initialized")
        } else if let mockAuthManager = authManager as? MockAuthenticationManager {
            mockAuthManager.$isAuthenticated.assign(to: &$isAuthenticated)
            mockAuthManager.$showAuthWebView.assign(to: &$showAuthWebView)
        }
    }
    
    func authenticate() {
        authManager.authenticate()
    }
    
    func checkAuthentication(cookies: [HTTPCookie]) {
        showAuthWebView = false
        if authManager.isValidAuthCookies(cookies: cookies) {
            shouldShowInitialSetupView = true
        } else {
            
        }
    }
}
