//
//  SettingsView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.openURL) private var openURL
    @ObservedObject var alertObject: AlertObject
    @AppStorage(K.UserDefaults.authenticationConfigured) private var isAuthenticationConfigured = false
    @State var path = NavigationPath()
    @State var isShowAlert = false
    
    private let contactFormURLString = "https://forms.gle/Tceg32xcH8avj8qy5"
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink("利用規約", destination: MarkdownView(filename: "term_of_service"))
                    NavigationLink("プライバシーポリシー", destination: MarkdownView(filename: "privacy_policy"))
                }
                
                Section {
                    Button("お問い合わせ") {
                        alertObject.showDouble(
                            isPresented: $isShowAlert,
                            title: "",
                            message: "お問い合わせフォームを外部ブラウザで開きます。\nよろしいですか？",
                            action: { openURL(URL(string: contactFormURLString)!)})
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await confirmClearData()
                        }
                    }) {
                        Text("すべてのデータを消去")
                            .foregroundColor(.red)
                    }
                }
                
#if DEBUG
                Section {
                    Button("ログイン") {
                        viewModel.authenticate()
                    }
                    .sheet(isPresented: $viewModel.showAuthWebView) {
                        WebView(isPresented: $viewModel.isAuthenticated, viewModel: viewModel, urlString: "https://note.com/login")
                    }
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.logout()
                                alertObject.showSingle(
                                    isPresented: $isShowAlert,
                                    title: "ログアウト完了",
                                    message: "ログアウトが完了しました。初期設定画面に戻ります。") {
                                    isAuthenticationConfigured = false
                                }
                            } catch KeychainError.unexpectedStatus(let status) {
                                alertObject.showSingle(
                                    isPresented: $isShowAlert,
                                    title: "エラー",
                                    message: "ログアウト処理中にエラーが発生しました。\n Keychain error status: \(status)"
                                )
                            } catch {
                                alertObject.showSingle(
                                    isPresented: $isShowAlert,
                                    title: "エラー",
                                    message: "ログアウト処理中に不明なエラーが発生しました。"
                                )
                            }
                        }
                    }) {
                        Text("ログアウト")
                            .foregroundColor(.red)
                    }
                }
#endif
                
            }
            .customAlert(for: alertObject, isPresented: $isShowAlert)
        }
    }
    
    private func confirmClearData() async {
        alertObject.showDouble(
            isPresented: $isShowAlert,
            title: "すべてのデータを消去",
            message: "\n●これまで取得した統計データ\n●noteへのログイン情報\n\nこれらがすべて消去され、アプリが初期状態に戻ります。\nこの操作は取り消すことができません。\n\n消去を実行しますか？",
            actionText: "消去する",
            action: { Task { await clearAllData() } },
            actionRole: .destructive
        )
    }
    
    private func clearAllData() async {
        do {
            try await viewModel.clearAllData()
            alertObject.showSingle(
                isPresented: $isShowAlert,
                title: "消去完了",
                message: "すべてのデータの消去が完了しました。初期設定画面に戻ります。") {
                isAuthenticationConfigured = false
            }
        } catch KeychainError.unexpectedStatus(let status) {
            alertObject.showSingle(
                isPresented: $isShowAlert,
                title: "エラー",
                message: "処理中にエラーが発生しました。\n Keychain error status: \(status)"
            )
        } catch {
            alertObject.showSingle(
                isPresented: $isShowAlert,
                title: "エラー",
                message: "処理中に不明なエラーが発生しました。"
            )
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
            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
