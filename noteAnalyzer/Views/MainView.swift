//
//  MainView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct MainView: View {
    @State var selectedToolBar = 1
    @ObservedObject var alertObject: AlertObject

    var body: some View {
            TabView {
                DashboardView(alertObject: alertObject)
                    .tabItem {
                        Label("ダッシュボード ", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                SettingsView(alertObject: alertObject)
                    .tabItem {
                        Label("設定", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    static let alertObject = AlertObject()
    
    static var previews: some View {
        MainView(alertObject: alertObject)
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
