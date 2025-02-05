//
//  View+DisableAnimationModifier.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/14.
//

import SwiftUI

@available(iOS 14.0, *)
public struct DisableAnimationModifier: ViewModifier {
    @Environment(\.isPresented) var isPresented: Bool
    
    public init() {
        UIView.setAnimationsEnabled(false)
    }
    
    public func body(content: Content) -> some View {
        content
//            .transaction {
//                $0.disablesAnimations = true
//            }
            .onChange(of: isPresented, initial: false) {
                print("onChange")
                UIView.setAnimationsEnabled(false)
            }
            .onAppear {
                UIView.setAnimationsEnabled(true)
            }
            .onDisappear {
                UIView.setAnimationsEnabled(true)
            }
    }
}

public extension View {
    @available(iOS 14.0, *)
    func disablesSheetAnimations() -> some View {
        modifier(DisableAnimationModifier())
    }
}
