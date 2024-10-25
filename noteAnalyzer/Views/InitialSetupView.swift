//
//  InitialSetupView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/26.
//

import SwiftUI

struct InitialSetupView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @StateObject private var alertObject = AlertObject()
    @State private var isPresentedProgressView = false
    @State private var shouldShowLoginCredentialMismatchView = false
    @State private var shouldShowIsCompleteInitialSetupView = false
    @State var isShowAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("ログイン処理が完了しました")
                    .padding(.vertical)
                Text("アプリを利用するには、ダッシュボードを取得する必要があります。")
                
                Spacer()
                
                Button("ダッシュボードを取得する") {
                    Task {
                        do {
                            isPresentedProgressView = true
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
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                        .tint(Color.white)
                        .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("処理中です")
                }
            }
        }
        .onAppear {
            Task {
//                await verifyLoginConsistency()
            }
        }
        .navigationDestination(isPresented: $shouldShowIsCompleteInitialSetupView) {
            IsCompleteInitialSetupView()
        }
        .navigationBarBackButtonHidden(true)
        .customAlert(for: alertObject, isPresented: $isShowAlert)
    }
    
    private func verifyLoginConsistency() async {
        isPresentedProgressView = true
        // ここにAPIからurlnameを取得するロジックを書く。たぶんViewModelから呼び出す。
        do {
            try await viewModel.verifyLoginConsistency()
            isPresentedProgressView = false
        } catch NAError.Auth.loginCredentialMismatch {
            shouldShowLoginCredentialMismatchView.toggle()
        } catch {
            print(error)
        }
    }
}

struct InitialSetupView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        InitialSetupView()
            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
