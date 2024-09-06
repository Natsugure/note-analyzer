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
    @ObservedObject var alertObject: AlertObject
    @AppStorage(K.UserDefaults.authenticationConfigured) private var isAuthenticationConfigured = false
    @State var path = NavigationPath()
    
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
                                alertObject.showSingle(title: "ログアウト完了", message: "ログアウトが完了しました。初期設定画面に戻ります。") {
                                    isAuthenticationConfigured = false
                                }
                            } catch KeychainError.unexpectedStatus(let status) {
                                alertObject.showSingle(title: "エラー", message: "ログアウト処理中にエラーが発生しました。\n Keychain error status: \(status)")
                            } catch {
                                alertObject.showSingle(title: "エラー", message: "ログアウト処理中に不明なエラーが発生しました。")
                            }
                        }
                    }) {
                        Text("ログアウト")
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        Task {
                            do {
                                try await viewModel.clearAllData()
                                alertObject.showSingle(title: "消去完了", message: "すべてのデータの消去が完了しました。初期設定画面に戻ります。") {
                                    isAuthenticationConfigured = false
                                }
                            } catch KeychainError.unexpectedStatus(let status) {
                                alertObject.showSingle(title: "エラー", message: "処理中にエラーが発生しました。\n Keychain error status: \(status)")
                            } catch {
                                alertObject.showSingle(title: "エラー", message: "処理中に不明なエラーが発生しました。")
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
    static let alertObject = AlertObject()
    
    static var previews: some View {
        SettingsView(alertObject: alertObject)
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
