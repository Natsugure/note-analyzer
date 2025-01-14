//
//  BackgroundClearProgressView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/14.
//

import SwiftUI

struct BackgroundClearProgressBarView: View {
    @Binding var progressValue: Double {
        willSet {
            UIView.setAnimationsEnabled(false)
        }
    }
    
    init(progressValue: Binding<Double>) {
        UIView.setAnimationsEnabled(false)
        self._progressValue = progressValue
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressBarView(progress: $progressValue)
                .padding()
                .presentationBackground(Color.clear)
        }
        .onAppear { UIView.setAnimationsEnabled(true) }
        .onDisappear { UIView.setAnimationsEnabled(true) }
    }
}

