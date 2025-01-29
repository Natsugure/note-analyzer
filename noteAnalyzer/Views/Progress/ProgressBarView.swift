//
//  ProgressView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/12/29.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double
    
    init(progress: Binding<Double>) {
        self._progress = progress
    }
    
    var body: some View {
        VStack {
            ProgressView(value: progress) {
                Text("データ取得中...")
                    .foregroundStyle(.white)
                    .padding(.bottom, 3)
            } currentValueLabel: {
                Text("\(String(Int(floor(progress * 100))))%")
                    .foregroundStyle(.white)
                    .padding(.top, 3)
            }
                .tint(Color.white)
                .padding()

        }
        .padding()
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ProgressBarView(progress: .constant(0.7))
}
