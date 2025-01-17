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
    @Published var alertEntity: AlertEntity?
    
    private let authManager: AuthenticationProtocol
    private var authWebViewModel: AuthWebViewModel?
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(authManager: AuthenticationProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authManager = authManager
        self.apiClient = apiClient
        self.realmManager = realmManager
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
    
    func makeInitialSetupViewModel() -> InitialSetupViewModel {
        InitialSetupViewModel(apiClient: apiClient, realmManager: realmManager)
    }
    
    func observeAuthWebViewModel(_ viewModel: AuthWebViewModel) {
        Task {
            authWebViewModel?.$isPresented.assign(to: &$isPresentedAuthWebView)
            authWebViewModel?.$shouldShowInitialSetupView.assign(to: &$shouldShowInitialSetupView)
        }
    }
}
