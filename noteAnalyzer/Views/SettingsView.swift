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
    @ObservedObject var alertObject = AlertObject()
    @State var path = NavigationPath()
    @State var shouldNavigateToOnboarding = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink("利用規約", destination: MarkdownView(filename: "term_of_service"))
                    NavigationLink("プライバシーポリシー", destination: MarkdownView(filename: "privacy_policy"))
                }
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.logout()
                                alertObject.showAlert(title: "ログアウト完了", message: "ログアウトが完了しました。初期設定画面に戻ります。") {
                                    shouldNavigateToOnboarding.toggle()
                                }
                            } catch KeychainError.unexpectedStatus(let status) {
                                alertObject.showAlert(title: "エラー", message: "ログアウト処理中にエラーが発生しました。\n Keychain error status: \(status)")
                            } catch {
                                alertObject.showAlert(title: "エラー", message: "ログアウト処理中に不明なエラーが発生しました。")
                            }
                        }
                    }) {
                        Text("ログアウト")
                            .foregroundColor(.red)
                    }
                    .navigationDestination(isPresented: $shouldNavigateToOnboarding) {
                        OnboardingView()
                    }
                    Button(action: {
                        Task {
                            // NoteViewModel.clearAllData()にもあとでthrowsを要追加。
                            do {
                                try await viewModel.clearAllData()
                                alertObject.showAlert(title: "消去完了", message: "すべてのデータの消去が完了しました。初期設定画面に戻ります。") {
                                    shouldNavigateToOnboarding.toggle()
                                }
                            } catch KeychainError.unexpectedStatus(let status) {
                                alertObject.showAlert(title: "エラー", message: "処理中にエラーが発生しました。\n Keychain error status: \(status)")
                            } catch {
                                alertObject.showAlert(title: "エラー", message: "処理中に不明なエラーが発生しました。")
                            }
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
            .customAlert(for: alertObject)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        SettingsView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
