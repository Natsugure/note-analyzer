//
//  LoginWebView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/25.
//

import SwiftUI

struct AuthWebView: View {
    @StateObject var viewModel: AuthWebViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                WrappedWebView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        viewModel.isPresented = false
                    }
                }
            }
            .navigationTitle("noteへログイン")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//struct AuthWebView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    
//    static var previews: some View {
//        AuthWebView()
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}

