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
    @Published var isPresentedAuthWebView = false
    @Published var shouldShowInitialSetupView = false
    @Published var isShowAlert = false
    
    private let authManager: AuthenticationProtocol
    private var authWebViewModel: AuthWebViewModel?
    
    init(authManager: AuthenticationProtocol) {
        self.authManager = authManager
    }
    
    func showAuthWebView() {
        isPresentedAuthWebView = true
    }
    
    func makeAuthWebViewModel() -> AuthWebViewModel {
        let viewModel: AuthWebViewModel
        if AppConfig.isDemoMode {
            viewModel = DemoAuthWebViewModel(authManager: authManager)
        } else {
            viewModel = AuthWebViewModel(authManager: authManager)
        }
        
        authWebViewModel = viewModel
        observeAuthWebViewModel(viewModel)
        
        return viewModel
    }
    
    func observeAuthWebViewModel(_ viewModel: AuthWebViewModel) {
        Task {
            authWebViewModel?.$isPresented.assign(to: &$isPresentedAuthWebView)
            authWebViewModel?.$shouldShowInitialSetupView.assign(to: &$shouldShowInitialSetupView)
        }
    }
}
