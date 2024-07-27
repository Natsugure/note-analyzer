//
//  HomeView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/27.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("ホーム")
            }
            .navigationTitle("note Analyzer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //更新ボタン
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await networkManager.getStats()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
