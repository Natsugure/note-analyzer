//
//  SettingsView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @EnvironmentObject var viewModel: NoteViewModel
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
                            await viewModel.clearAllData()
                        }
                    }) {
                        Text("すべてのデータを消去")
                            .foregroundColor(.red)
                    }
                }
                        Button("ログイン") {
                            viewModel.authenticate()
                        }
                        .sheet(isPresented: $viewModel.showAuthWebView) {
                            WebView(isPresented: $viewModel.isAuthenticated, viewModel: viewModel, urlString: "https://note.com/login")
                        }
            }
        }
    }
}

#Preview {
    SettingsView()
//        .environmentObject(NetworkService())
}
