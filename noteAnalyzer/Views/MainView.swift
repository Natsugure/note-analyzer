//
//  MainView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct MainView: View {
    @State var selectedToolBar = 1
    @StateObject var alertObject = AlertObject()
//    @State private var isPresentedProgressView = false
    let apiClient: NoteAPIClient
    let realmManager: RealmManager
    
    var body: some View {
        ZStack {
            TabView {
                DashboardView(viewModel: DashboardViewModel(apiClient: apiClient, realmManager: realmManager))
                    .tabItem {
                        Label("ダッシュボード", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                SettingsView(viewModel: SettingsViewModel(apiClient: apiClient, realmManager: realmManager))
                    .tabItem {
                        Label("設定", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            
//            if isPresentedProgressView {
//                Color.black.opacity(0.3)
//                    .ignoresSafeArea()
//                ProgressBarView()
//                    .padding()
//            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

//struct MainView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    static let alertObject = AlertObject()
//    static let apiFetcher = NoteAPIFetcher(networkService: networkService)
//    
//    static var previews: some View {
//        MainView(alertObject: alertObject)
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager, apiFetcher: apiFetcher))
//    }
//}


