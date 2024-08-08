//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
//        if isFirstLaunch {
//            OnboardingView()
//        } else {
//            MainView()
//        }
        MainView()
    }
}

#Preview {
    ContentView()
}
