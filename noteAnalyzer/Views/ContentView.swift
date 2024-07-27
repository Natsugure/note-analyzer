//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    @State var selectedToolBar = 1
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(1)
            
            DashboardView()
                .tabItem {
                    Label("ダッシュボード", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
