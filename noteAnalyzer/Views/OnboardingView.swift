//
//  OnboardingView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/05.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    
    @State private var showTermModal = false
    @State private var showPrivacyModal = false
    @State private var shouldShowInitialSetupView = false
    @State private var agreedToTerms = false
    
    var body: some View {
        NavigationStack {
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
                Text("noteAnalyzerは、noteのダッシュボードを拡張する非公式アプリです。")
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
                                showTermModal = true
                            }
                            .foregroundColor(.blue)
                            .sheet(isPresented: $showTermModal) {
                                TermAndPolicyView(isShowModal: $showTermModal, fileName: "term_of_service")
                            }
                            Text("と")
                            Button("プライバシーポリシー") {
                                showPrivacyModal = true
                            }
                            .foregroundColor(.blue)
                            .sheet(isPresented: $showPrivacyModal) {
                                TermAndPolicyView(isShowModal: $showPrivacyModal, fileName: "privacy_policy")
                            }
                        }
                        
                        Text("に同意する必要があります。")
                    }
                    .padding()
                    
                    Button("同意してログイン画面へ") {
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
                }
                .padding()
            }
            .onChange(of: viewModel.showAuthWebView) { newValue in
                if viewModel.isAuthenticated && !newValue {
                    print("onchange")
                    shouldShowInitialSetupView.toggle()
                }
            }
            .navigationDestination(isPresented: $shouldShowInitialSetupView) {
                InitialSetupView()
            }
            .navigationBarBackButtonHidden(true)
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
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        OnboardingView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
