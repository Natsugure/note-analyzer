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
                Section {
                    NavigationLink("利用規約", destination: MarkdownView(filename: "term_of_service"))
                    NavigationLink("プライバシーポリシー", destination: MarkdownView(filename: "privacy_policy"))
                }
                
                Section {
                    Button("お問い合わせ") {
                        viewModel.openContactUsPage()
                    }
                    .onChange(of: viewModel.url) {
                        if let url = viewModel.url {
                            openURL(url)
                        }
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
            .customAlert(object: $viewModel.alertEntity)
        }
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
