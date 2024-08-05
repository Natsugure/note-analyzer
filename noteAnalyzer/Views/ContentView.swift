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
            DashboardView()
                .tabItem {
                    Label("ダッシュボード ", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
