//
//  MockAuthenticationManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation
import WebKit

class MockAuthenticationManager: ObservableObject, AuthenticationProtocol {
//    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    //TODO: ここにAuthWebView内の`@escaping`クロージャを移す。もしくはshowAuthWebViewのフラグ自体をViewModelに移す。
    // さらに言えば、AuthWebViewをWebViewDelegateに準拠させて、デリゲートパターンで通知するというのも手なのか？
    func authenticate() {
        Task { @MainActor in
            showAuthWebView = true
            
            //すぐに状態を変更するとOnboardingViewのonChangeが作動しないため遅延を追加
            try? await Task.sleep(nanoseconds: 500_000_000)
//            isAuthenticated = true
            showAuthWebView = false
        }
    }
    
    func isValidAuthCookies(cookies: [HTTPCookie]) -> Bool{
//        isAuthenticated = true
        showAuthWebView = false
        
        return true
    }
    
    func getCookies() -> [HTTPCookie] {
        // デモ用なのでCookieは不要
        return []
    }
    
    func clearAuthentication() throws {
//        isAuthenticated = false
    }
}
