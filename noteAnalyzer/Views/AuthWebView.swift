//
//  LoginWebView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/25.
//

import SwiftUI

struct AuthWebView: View {
    @StateObject var viewModel: AuthWebViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                WrappedWebView(viewModel: viewModel)
            }
            .onChange(of: viewModel.shouldExecuteCompletionHandler) {
                if viewModel.shouldExecuteCompletionHandler {
                    dismiss()
                }
            }
            .onAppear {
#if DEBUG
                Task {
                    if AppConfig.isDemoMode {
                        viewModel.shouldExecuteCompletionHandler = true
                    }
                }
#endif
            }
            .onDisappear {
                if viewModel.shouldExecuteCompletionHandler {
                    Task {
                        await viewModel.executeCompletionHandler()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
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

