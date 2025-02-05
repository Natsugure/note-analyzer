//
//  OnboardingView.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    
                    Text("Advanced Dashboard \nfor note")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Image(.appIconTransparent)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .foregroundColor(.black)
                        .padding(.bottom)
                    Text("このアプリは、noteのダッシュボードを拡張する非公式アプリです。")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 3)
                    Text("ダッシュボードを取得するにはnoteへのログインが必要です。")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack {
                        VStack {
                            HStack {
                                Text("サービスを利用開始するには、")
                            }
                            .multilineTextAlignment(.center)
                            
                            HStack {
                                Button("利用規約") {
                                    viewModel.showTermModal = true
                                }
                                .foregroundColor(.blue)
                                .sheet(isPresented: $viewModel.showTermModal) {
                                    TermAndPolicyView(isShowModal: $viewModel.showTermModal, fileName: "term_of_service")
                                }
                                Text("と")
                                Button("プライバシーポリシー") {
                                    viewModel.showPrivacyModal = true
                                }
                                .foregroundColor(.blue)
                                .sheet(isPresented: $viewModel.showPrivacyModal) {
                                    TermAndPolicyView(isShowModal: $viewModel.showPrivacyModal, fileName: "privacy_policy")
                                }
                            }
                            
                            Text("に同意する必要があります。")
                        }
                        .padding()
                        
                        Button("同意してログイン画面へ") {
                            viewModel.showAuthWebView()
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .sheet(isPresented: $viewModel.isPresentedAuthWebView) {
                            AuthWebView(viewModel: AuthWebViewModel { cookies in
                                Task {
                                    await viewModel.checkAuthentication(cookies: cookies)
                                }
                            })
                                .interactiveDismissDisabled()
                        }
                    }
                    .padding()
                }
                
                if viewModel.isPresentedProgressView {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    ProgressCircularView()
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldShowInitialSetupView) {
                InitialSetupView(viewModel: viewModel.makeInitialSetupViewModel())
            }
            .navigationBarBackButtonHidden(true)
            .customAlert(entity: $viewModel.alertEntity)
        }
    }
}


struct TermAndPolicyView: View {
    @Binding var isShowModal: Bool
    let fileName: String
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    if fileName == "term_of_service" {
                        Text("利用規約")
                            .font(.system(.title3, weight: .bold))
                            .frame(width: geometry.size.width, alignment: .center)
                    } else {
                        Text("プライバシーポリシー")
                            .font(.system(.title3, weight: .bold))
                            .frame(width: geometry.size.width, alignment: .center)
                    }
                    
                    Button("閉じる") {
                        isShowModal.toggle()
                    }
                    .padding(.trailing)
                    .frame(width: geometry.size.width, alignment: .trailing)
                }
                .frame(height: geometry.size.height)
                .padding(.vertical, 8)
            }
            .frame(height: 44)
            MarkdownView(filename: fileName)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static let mockAuthManager = MockAuthenticationService()
    static let provider = MockDataProvider()
    static let realmManager = RealmManager()
    static let networkService = MockNetworkService(provider: provider)
    static let apiFetcher = NoteAPIClient(authManager: mockAuthManager, networkService: networkService)
    static var viewModel = OnboardingViewModel(authManager: mockAuthManager, apiClient: apiFetcher, realmManager: realmManager)
    
    static var previews: some View {
        OnboardingView(viewModel: viewModel)
    }
}
