//
//  View+DisableAnimationModifier.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/14.
//

import SwiftUI

@available(iOS 14.0, *)
public struct DisableAnimationModifier: ViewModifier {
    @Environment(\.isPresented) var isPresented: Bool
    @StateObject var alertObject = AlertObject()
    @State var isAlert = false
    
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
            .customAlert(for: alertObject, isPresented: $isAlert)
    }
}

public extension View {
    @available(iOS 14.0, *)
    func disablesSheetAnimations() -> some View {
        modifier(DisableAnimationModifier())
    }
}
