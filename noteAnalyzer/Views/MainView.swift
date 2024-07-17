//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI
import RealmSwift

struct MainView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationStack {
            Button("データ取得") {
                Task {
                    await networkManager.getStats()
                }
            }
            .padding()
            
            Button("ログイン") {
                networkManager.authenticate()
            }
            .sheet(isPresented: $networkManager.showAuthWebView) {
                WebView(isPresented: $networkManager.isAuthenticated, networkManager: networkManager, urlString: "https://note.com/login")
            }
        }
    }
}

#Preview {
    MainView()
}
