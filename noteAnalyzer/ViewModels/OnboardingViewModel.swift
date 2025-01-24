//
//  OnboardingViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/08.
//

import Foundation
import WebKit

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isPresentedAuthWebView = false
    @Published var didFinishLogin = false
    @Published var showTermModal = false
    @Published var showPrivacyModal = false
    @Published var isPresentedProgressView = false
    @Published var shouldShowInitialSetupView = false
    @Published var isShowAlert = false
    @Published var alertEntity: AlertEntity?
    
    private let authService: AuthenticationServiceProtocol
    private var authWebViewModel: AuthWebViewModel?
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(authManager: AuthenticationServiceProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authService = authManager
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    func showAuthWebView() {
        isPresentedAuthWebView = true
    }
    
    func makeAuthWebViewModel() -> AuthWebViewModel {
        let viewModel: AuthWebViewModel
        if AppConfig.isDemoMode {
            viewModel = DemoAuthWebViewModel()
        } else {
            viewModel = AuthWebViewModel()
        }
        
        authWebViewModel = viewModel
        observeAuthWebViewModel()
        
        return viewModel
    }
    
    private func observeAuthWebViewModel() {
        authWebViewModel?.$isPresented.assign(to: &$isPresentedAuthWebView)
        authWebViewModel?.$didFinishLogin.assign(to: &$didFinishLogin)
    }
    
    func checkAuthentication() async {
        isPresentedProgressView = true
        
        let allCookies = await WKWebsiteDataStore.default().httpCookieStore.allCookies()
        
        do {
            try await authService.authenticate(cookies: allCookies)
            
            isPresentedProgressView = false
            shouldShowInitialSetupView = true
        } catch {
            isPresentedProgressView = false
            
            try? await Task.sleep(for: .seconds(0.5))
            handleError(error)
        }
    }
    
    func makeInitialSetupViewModel() -> InitialSetupViewModel {
        InitialSetupViewModel(apiClient: apiClient, realmManager: realmManager)
    }
    
    private func handleError(_ error: Error) {
        print(error)
        
        let title: String
        let message: String
        
        switch error {
        case NAError.auth(let detail):
            title = "認証エラー"
            message = detail.userMessage
            
        case NAError.network(_), NAError.decoding(_):
            let detail = error as! NAError
            title = "ネットワークエラー"
            message = detail.userMessage
            
        default:
            title = "不明なエラー"
            message = "認証中に不明なエラーが発生しました。"
        }
        
        alertEntity = .init(singleButtonAlert: title, message: message)
    }
}
