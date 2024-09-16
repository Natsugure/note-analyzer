//
//  IsCompleteInitialSetupView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/09/06.
//

import SwiftUI

struct IsCompleteInitialSetupView: View {
    @EnvironmentObject private var viewModel: NoteViewModel
    @AppStorage(K.UserDefaults.authenticationConfigured) private var isAuthenticationConfigured = false
    @State private var shouldShowMainView = false
    
    var body: some View {
        VStack {
            Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color.green)
                    .frame(width: 100, height: 100)
            .padding()
            Text("ダッシュボードの取得が完了しました！")
            Spacer()
            Button("メイン画面へ移動する") {
                isAuthenticationConfigured = true
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct IsCompleteInitialSetupView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        IsCompleteInitialSetupView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
