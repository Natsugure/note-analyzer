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
    @State private var isPresentedProgressView = false
    
    var body: some View {
        ZStack {
            TabView {
                DashboardView(alertObject: alertObject, isPresentedProgressView: $isPresentedProgressView)
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
            
            if isPresentedProgressView {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.white)
                        .padding()
                    Text("処理中です")
                        .foregroundStyle(.white)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .navigationBarBackButtonHidden(true)
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
