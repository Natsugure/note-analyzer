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
            .fullScreenCover(isPresented: $viewModel.showLoadingView) {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .ignoresSafeArea()
                    
                    ProgressCircularView()
                }
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
//    static var previews: some View {
//        AuthWebView(viewModel: AuthWebViewModel(didFinishLoginOnAuthWebView: .constant(false)))
//    }
//}

