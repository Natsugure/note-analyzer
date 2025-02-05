//
//  InitialSetupView.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/08/26.
//

import SwiftUI

struct InitialSetupView: View {
    @StateObject var viewModel: InitialSetupViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("ログイン処理が完了しました")
                    .font(.title)
                    .padding(.vertical)
                
                VStack {
                    Text("アプリを利用するには、noteのサーバーから統計情報を取得する必要があります。")
                    Text("以下のボタンをタップすると、現時点での総ビュー・スキ・コメント数を取得します。".insertWordJoiner())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                }
                .padding(.vertical, 100)
                
                Spacer()
                
                Button("統計情報を取得する") {
                    Task {
                        await viewModel.fetchStats()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()

            if viewModel.isPresentedProgressView {
                Color.white
                ProgressBarView(progress: $viewModel.progressValue)
                    .padding()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldShowCompleteInitialSetupView) {
            CompleteInitialSetupView()
        }
        .navigationBarBackButtonHidden(true)
        .customAlert(entity: $viewModel.alertEntity)
    }
}

struct InitialSetupView_Previews: PreviewProvider {
    static let authManager = MockAuthenticationService()
    static let networkService = NetworkService()
    static let apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        InitialSetupView(viewModel: InitialSetupViewModel(apiClient: apiClient, realmManager: realmManager))
    }
}
