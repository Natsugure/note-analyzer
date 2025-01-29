//
//  ProgressCircularView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/08.
//

import SwiftUI

struct ProgressCircularView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .onAppear {
            print("progress appear")
        }
    }
}

#Preview {
    ProgressCircularView()
}
