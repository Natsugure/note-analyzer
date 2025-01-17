//
//  InitialSetupView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/26.
//

import SwiftUI

struct InitialSetupView: View {
    @StateObject var viewModel: InitialSetupViewModel
    @State private var isPresentedProgressView = false
    @State private var shouldShowLoginCredentialMismatchView = false
    @State private var shouldShowIsCompleteInitialSetupView = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("ログイン処理が完了しました")
                    .font(.title)
                    .padding(.vertical)
                Spacer()
                //TODO: ここでチュートリアル画面を分けて、説明文を増やす。毎日取得すると徐々にデータが集まってきますみたいな。
                Text("アプリを利用するには、統計情報を取得する必要があります。")
                Text("以下のボタンをタップすると、以下の期間のビュー・スキ・コメント数を取得します。".insertWordJoiner())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                Text("●  全期間通算\n●  1週間前\n●  1ヶ月前\n●  1年前")
                Text("※noteのサーバーから取得できる情報に制限があるため、上記の区切りのみとなります。ご了承ください。")
                    .padding(.vertical)
                
                Spacer()
                
                Button("ダッシュボードを取得する") {
                    Task {
                        isPresentedProgressView = true
                        do {
                            try await viewModel.getStats()
                            isPresentedProgressView = false
                            shouldShowIsCompleteInitialSetupView.toggle()
                        } catch {
                            shouldShowIsCompleteInitialSetupView.toggle()
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()

            
            if isPresentedProgressView {
                Color.white
                ProgressBarView(progress: $viewModel.progressValue)
                    .padding()
            }
        }
        .onAppear {
            Task {
//                await verifyLoginConsistency()
            }
        }
        .navigationDestination(isPresented: $shouldShowIsCompleteInitialSetupView) {
            CompleteInitialSetupView()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func verifyLoginConsistency() async {
//        isPresentedProgressView = true
//        // ここにAPIからurlnameを取得するロジックを書く。たぶんViewModelから呼び出す。
//        do {
//            try await viewModel.verifyLoginConsistency()
//            isPresentedProgressView = false
//        } catch NAError.Auth.loginCredentialMismatch {
//            shouldShowLoginCredentialMismatchView.toggle()
//        } catch {
//            print(error)
//        }
    }
}

//struct InitialSetupView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    
//    static var previews: some View {
//        InitialSetupView()
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}
