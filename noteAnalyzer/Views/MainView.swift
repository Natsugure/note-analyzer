//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI
import RealmSwift

struct MainView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationStack {
            Button("データ取得") {
                Task {
                    await networkManager.getStats()
                }
            }
            Spacer()
            Button("ログイン") {
                Task {
                    do {
                        try await networkManager.login(email: "natsugure5301102@gmail.com", password: "SwyedKJqZpSeU6")
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
