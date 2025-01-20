//
//  MockAuthenticationManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation
import WebKit

class MockAuthenticationManager: ObservableObject, AuthenticationProtocol {
    
    func isValidAuthCookies(cookies: [HTTPCookie]) -> Bool {
        return true
    }
    
    func getCookies() -> [HTTPCookie] {
        // デモ用なのでCookieは不要
        return []
    }
    
    func clearAuthentication() throws {}
}
