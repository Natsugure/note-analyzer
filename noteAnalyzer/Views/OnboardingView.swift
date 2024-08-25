//
//  OnboardingView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    @ObservedObject var alertObject: AlertObject
    
    @State private var showTermModal = false
    @State private var showPrivacyModal = false
    @State private var shouldShowMainView = false
    
    var body: some View {
        VStack {
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
            Text("noteAnalyzerは、noteのダッシュボードを拡張するアプリです。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 3)
            Text("ダッシュボードを取得するにはnoteへのログインが必要です。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack {
                Button("ログイン画面へ") {
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
        .onChange(of: viewModel.isAuthenticated) { newValue in
            if newValue {
                alertObject.showSingle(
                    title: "ログイン完了",
                    message: "ログインが正常に完了しました。" ,
                    action: {
                        shouldShowMainView.toggle()
                    })
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    static let alertObject = AlertObject()
    
    static var previews: some View {
        OnboardingView(alertObject: alertObject)
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
