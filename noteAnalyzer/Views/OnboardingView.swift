//
//  OnboardingView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @EnvironmentObject var viewModel: NoteViewModel
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                MainView()
            } else {
                Text("noteAnalyzer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "chart.bar.xaxis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.black)
                    .padding(.bottom)
                Text("noteAnalyzerはnoteのダッシュボードを拡張するアプリです。")
                    .padding(.horizontal)
                Text("ダッシュボードを取得するにはnoteへのログインが必要です。")
                    .padding(.horizontal)
                
                Button("ログイン画面を開く") {
                    viewModel.authenticate()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding()
                .sheet(isPresented: $viewModel.showAuthWebView) {
                    WebView(isPresented: $viewModel.isAuthenticated, viewModel: viewModel, urlString: "https://note.com/login")
                }
            }
        }
        .onChange(of: viewModel.isAuthenticated) { newValue in
            if newValue {
                isFirstLaunch = false
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        OnboardingView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
