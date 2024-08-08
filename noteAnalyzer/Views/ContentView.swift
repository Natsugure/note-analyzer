//
//  ContentView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
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
