//
//  EnvironmentValues+SetIsPresentedOnboardingViewAction.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/20.
//

import SwiftUICore

struct SetIsPresentedOnboardingViewAction {
    private var isPresented: Binding<Bool>
    
    init(isPresented: Binding<Bool>) {
        self.isPresented = isPresented
    }
    
    func callAsFunction(_ newValue: Bool) {
        isPresented.wrappedValue = newValue
    }
}

extension EnvironmentValues {
    @Entry var SetIsPresentedOnboardingView = SetIsPresentedOnboardingViewAction(isPresented: .constant(false))
}
