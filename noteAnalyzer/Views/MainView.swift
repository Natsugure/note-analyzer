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
            NavigationLink(destination: WebView(urlString: "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv")) {
                Text("WebViewを開く")
            }
        }
    }
}

#Preview {
    MainView()
}
