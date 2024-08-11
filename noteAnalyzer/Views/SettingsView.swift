//
//  SettingsView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink("利用規約", destination: MarkdownView(filename: "term_of_service"))
                    NavigationLink("プライバシーポリシー", destination: MarkdownView(filename: "privacy_policy"))
                }
                Section {
//                    Button(action: {
//                        //                        networkManager.logout()
//                    }) {
//                        Text("ログアウト")
//                            .foregroundColor(.red)
//                    }
                    Button(action: {
                        Task {
                            await networkManager.clearAllData()
                        }
                    }) {
                        Text("すべてのデータを消去")
                            .foregroundColor(.red)
                    }
                }
                        Button("ログイン") {
                            networkManager.authenticate()
                        }
                        .sheet(isPresented: $networkManager.showAuthWebView) {
                            WebView(isPresented: $networkManager.isAuthenticated, networkManager: networkManager, urlString: "https://note.com/login")
                        }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NetworkManager())
}
