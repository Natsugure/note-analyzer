//
//  IsCompleteInitialSetupView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/09/06.
//

import SwiftUI

struct CompleteInitialSetupView: View {
    @State private var shouldShowMainView = false
    @Environment(\.SetIsPresentedOnboardingView) var setIsPresentedOnboardingView
    
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
                setIsPresentedOnboardingView(false)
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

#Preview {
    CompleteInitialSetupView()
}
