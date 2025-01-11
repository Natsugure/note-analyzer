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
    @State var path = NavigationPath()
    @State var isShowAlert = false
    
    private let contactFormURLString = "https://forms.gle/Tceg32xcH8avj8qy5"
    
#if DEBUG
//    @AppStorage(AppConstants.UserDefaults.demoModekey) private var isDemoMode = false
    @State private var isDemoMode = AppConfig.isDemoMode
#endif
    
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
//                    Button("ログイン") {
//                        viewModel.authenticate()
//                    }
//                    .sheet(isPresented: $viewModel.isPresentedAuthWebView) {
//                        WebView(isPresented: $viewModel.isAuthenticated, viewModel: <#OnboardingViewModel#>, urlString: "https://note.com/login")
//                    }
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.logout()
                                alertObject.showSingle(
                                    isPresented: $isShowAlert,
                                    title: "ログアウト完了",
                                    message: "ログアウトが完了しました。初期設定画面に戻ります。") {
                                        AppConfig.isAuthenticationConfigured = false
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
                
                Section {
                    Toggle("デモモード", isOn: $isDemoMode)
                    Text("デモモードON : モックデータを使用してアプリを使用します。\nデモモードOFF: 実際にnoteのアカウントを使用してダッシュボードを取得します。\n\n変更するとただちにアプリ内データの消去を実行し、変更を適用します。")
                }
                .onChange(of: isDemoMode) { newValue in
                    Task {
                        await changeDemoModeKey()
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
                message: "すべてのデータの消去が完了しました。初期設定画面に戻ります。",
                action: { AppConfig.isAuthenticationConfigured = false }
            )
        } catch {
            handleClearAllDataError(error)
        }
    }
    
    private func changeDemoModeKey() async {
        do {
            AppConfig.isDemoMode.toggle()
            print("appConfig.isDemoMode: \(AppConfig.isDemoMode)")
            try await viewModel.clearAllData()
            showRestartAlert()
        } catch {
            handleClearAllDataError(error)
        }
    }
    
    private func showRestartAlert() {
        alertObject.showSingle(
            isPresented: $isShowAlert,
            title: "アプリの再起動が必要",
            message: "デモモードの設定を反映するには、アプリの再起動が必要です。",
            action: {
                Task {
                    AppConfig.isAuthenticationConfigured = false
                    try? await Task.sleep(for: .seconds(0.5))
                    exit(0)
                }
            }
        )
    }
    
    private func handleClearAllDataError(_ error: any Error) {
        let detail: String
        
        if let keychainError = error as? KeychainError {
            switch keychainError {
            case .unexpectedStatus(let status):
                detail = "処理中にエラーが発生しました。\n 認証情報の消去に失敗しました。\nエラーコード: \(status)"
                
            default:
                detail = "処理中に不明なエラーが発生しました。\n\(error.localizedDescription)"
            }
        } else {
            detail = "処理中に不明なエラーが発生しました。"
        }
        
        alertObject.showSingle(
            isPresented: $isShowAlert,
            title: "初期化エラー",
            message: detail
        )
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    static let alertObject = AlertObject()
//    
//    static var previews: some View {
//        SettingsView(alertObject: alertObject)
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}
