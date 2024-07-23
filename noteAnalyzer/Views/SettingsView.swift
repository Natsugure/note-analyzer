//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/21.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {

    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        Button("ログイン") {
            networkManager.authenticate()
        }
        .sheet(isPresented: $networkManager.showAuthWebView) {
            WebView(isPresented: $networkManager.isAuthenticated, networkManager: networkManager, urlString: "https://note.com/login")
        }
    }
}

#Preview {
    SettingsView()
}
