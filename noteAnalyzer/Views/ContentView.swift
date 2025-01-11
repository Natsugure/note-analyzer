//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

extension ContentView {
    init() {
#if DEBUG
        if AppConfig.isDemoMode {
            print("demoMode")
            let mockAuthManager = MockAuthenticationManager()
            self.authManager = mockAuthManager
            _viewModel = StateObject(wrappedValue: DemoViewModel())
        } else {
            print("normalMode")
            let authManager = AuthenticationManager()
            self.authManager = authManager
            
            let networkService = NetworkService(authManager: authManager)
            let realmManager = RealmManager()
            let apiFetcher = NoteAPIFetcher(networkService: networkService)
            
            _viewModel = StateObject(
                wrappedValue: ViewModel(
                    authManager: authManager,
                    networkService: networkService,
                    realmManager: realmManager,
                    apiFetcher: apiFetcher
                )
            )
        }
#else
        let authManager = AuthenticationManager()
        self.authManager = authManager
        
        let networkService = NetworkService(authManager: authManager)
        let realmManager = RealmManager()
        let apiFetcher = NoteAPIFetcher(networkService: networkService)
        
        _viewModel = StateObject(
            wrappedValue: ViewModel(
                authManager: authManager,
                networkService: networkService,
                realmManager: realmManager,
                apiFetcher: apiFetcher
            )
        )
#endif
    }
}

struct ContentView: View {
    @StateObject private var viewModel: ViewModel
    // TODO: AppStorageをやめて、UserDefaultプロパティラッパーで値を監視できるようにしたほうが良さげ。
    @AppStorage(AppConfig.$isAuthenticationConfigured.key.rawValue) private var isAuthenticationConfigured = false
    let authManager: AuthenticationProtocol
    
    var body: some View {
        if !isAuthenticationConfigured {
            OnboardingView(viewModel: OnboardingViewModel(authManager: authManager))
                .environmentObject(viewModel)
        } else {
            MainView()
                .environmentObject(viewModel)
        }
    }
}

//struct Content_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    
//    static var previews: some View {
//        ContentView()
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}
