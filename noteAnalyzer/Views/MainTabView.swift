//
//  MainView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct MainTabView: View {
    @State var isPresentedOnboardingView = false
    @State var selectedTabBarIndex = 1
    let authService: AuthenticationServiceProtocol
    let apiClient: NoteAPIClient
    let realmManager: RealmManager
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTabBarIndex) {
                DashboardView(viewModel: DashboardViewModel(apiClient: apiClient, realmManager: realmManager))
                    .tabItem {
                        Label("ダッシュボード", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                SettingsView(
                    viewModel: SettingsViewModel(authService: authService, apiClient: apiClient, realmManager: realmManager),
                    selectedTabBarIndex: $selectedTabBarIndex
                )
                    .tabItem {
                        Label("設定", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .fullScreenCover(isPresented: $isPresentedOnboardingView) {
                OnboardingView(
                    viewModel: OnboardingViewModel(
                        authManager: authService,
                        apiClient: apiClient,
                        realmManager: realmManager
                    )
                )
            }
        }
        .onAppear {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            
            withTransaction(transaction) {
                isPresentedOnboardingView = !AppConfig.isCompletedInitialSetup
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.SetIsPresentedOnboardingView, .init(isPresented: $isPresentedOnboardingView))
    }
}

struct MainView_Previews: PreviewProvider {
    static let authManager = MockAuthenticationService()
    static let networkService = NetworkService()
    static let apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        MainTabView(authService: authManager, apiClient: apiClient, realmManager: realmManager)
    }
}


