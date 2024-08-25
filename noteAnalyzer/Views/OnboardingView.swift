//
//  OnboardingView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(K.UserDefaults.isFirstLaunch) var isFirstLaunch: Bool = true
    @EnvironmentObject var viewModel: NoteViewModel
    
    @State private var shouldShowMainView = false
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                MainView()
            } else {
                Spacer()
                
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
                
                Spacer()
                
                VStack {
                    Button("続ける") {
                        viewModel.authenticate()
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .sheet(isPresented: $viewModel.showAuthWebView) {
                        AuthWebView()
                            .interactiveDismissDisabled()
                    }
                    //「利用規約」と「プライバシーポリシー」の文字にリンクを付けたい。
                    Text("サービスを利用開始すると、利用規約 と プライバシーポリシー に同意したこととなります。")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
                .padding()
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
