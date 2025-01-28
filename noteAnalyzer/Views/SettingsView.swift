//
//  SettingsView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Binding var selectedTabBarIndex: Int
    @Environment(\.SetIsPresentedOnboardingView) var isPresentedOnboardingView
    @Environment(\.openURL) private var openURL
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("認証がうまくいかない場合は、こちらから再認証してください。") {
                    Button("再認証") {
                        Task {
                            await viewModel.reauthorize()
                        }
                    }
                }
                
                Section {
                    Button("アプリの使い方") {
                        viewModel.openHowToUse()
                    }
                    NavigationLink("利用規約", destination: MarkdownView(filename: "term_of_service"))
                    NavigationLink("プライバシーポリシー", destination: MarkdownView(filename: "privacy_policy"))
                }
                
                Section {
                    Button("お問い合わせ") {
                        viewModel.openContactUsPage()
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.confirmClearData()
                    }) {
                        Text("すべてのデータを消去")
                            .foregroundColor(.red)
                    }
                }
                
#if DEBUG
                Section {
                    Toggle("デモモード", isOn: $viewModel.isDemoMode)
                    Text("デモモードON : モックデータを使用してアプリを使用します。\nデモモードOFF: 実際にnoteのアカウントを使用してダッシュボードを取得します。\n\n変更するとただちにアプリ内データの消去を実行し、変更を適用します。")
                }
                .onChange(of: viewModel.isDemoMode) {
                    Task {
                        await viewModel.changeDemoModeKey()
                    }
                }
                .onChange(of: viewModel.shouldShowOnboardingView) {
                    selectedTabBarIndex = 1
                    isPresentedOnboardingView(true)
                }
#endif
            }
            .sheet(isPresented: $viewModel.isPresentedAuthWebView) {
                AuthWebView(viewModel: AuthWebViewModel { cookies in
                    Task {
                        await viewModel.checkAuthentication(cookies: cookies)
                    }
                })
            }
            .onChange(of: viewModel.url) {
                if let url = viewModel.url {
                    openURL(url)
                }
            }
            .customAlert(entity: $viewModel.alertEntity)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let authService = MockAuthenticationService()
    static let provider = MockDataProvider()
    static let networkService = MockNetworkService(provider: provider)
    static let apiClient = NoteAPIClient(authManager: authService, networkService: networkService)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        SettingsView(
            viewModel: SettingsViewModel(
                authService: authService,
                apiClient: apiClient,
                realmManager: realmManager
            ),
            selectedTabBarIndex: .constant(2)
        )
    }
}
