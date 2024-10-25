//
//  MockAuthenticationManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation
import WebKit

class MockAuthenticationManager: ObservableObject, AuthenticationProtocol {
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    func authenticate() {
        Task { @MainActor in
            showAuthWebView = true
            
            //すぐに状態を変更するとOnboardingViewのonChangeが作動しないため遅延を追加
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機
            isAuthenticated = true
            showAuthWebView = false
        }
    }
    
    func checkAuthentication(webView: WKWebView) {
        isAuthenticated = true
        showAuthWebView = false
    }
    
    func getCookies() -> [HTTPCookie] {
        // デモ用なのでCookieは不要
        return []
    }
    
    func clearAuthentication() throws {
        isAuthenticated = false
    }
}
