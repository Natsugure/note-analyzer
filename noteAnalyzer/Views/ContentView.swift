//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: NoteViewModel
    @StateObject private var alertObject = AlertObject()
    
    var body: some View {
        // isAuthenticatedを使用してViewを分けていると、別のビューでログイン・ログアウト処理を行うと速攻で切り替わってしまう。
        // 別の方法を検討する必要がある。
//        if !viewModel.isAuthenticated {
            OnboardingView(alertObject: alertObject)
//        } else {
//            MainView(alertObject: alertObject)
//        }
    }
}

struct Content_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        ContentView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
