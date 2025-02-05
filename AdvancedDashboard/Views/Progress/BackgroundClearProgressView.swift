//
//  BackgroundClearProgressView.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/14.
//

import SwiftUI

struct BackgroundClearProgressBarView: View {
    @Binding var progressValue: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressBarView(progress: $progressValue)
                .padding()
        }
    }
}

