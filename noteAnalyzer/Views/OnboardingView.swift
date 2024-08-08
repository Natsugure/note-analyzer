//
//  OnboardingView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        VStack {
            if networkManager.isAuthenticated {
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
                    networkManager.authenticate()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding()
                .sheet(isPresented: $networkManager.showAuthWebView) {
                    WebView(isPresented: $networkManager.isAuthenticated, networkManager: networkManager, urlString: "https://note.com/login")
                }
            }
        }
        .onChange(of: networkManager.isAuthenticated) { newValue in
            if newValue {
                isFirstLaunch = false
            }
        }
    }
}

#Preview {
    OnboardingView()
}
