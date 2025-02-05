//
//  MockAuthenticationManager.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/10/25.
//

import Foundation

class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldThrowReauthorizeError = false
    
    func authenticate(cookies: [HTTPCookie]) async throws {
        
    }
    
    private func saveUserProfiles() {
        AppConfig.urlname = "test"
        AppConfig.userId = 12345
    }
    
    func reauthorize(cookies: [HTTPCookie]) async throws {
        try verifySameUser()
    }
    
    private func verifySameUser() throws {
        if shouldThrowReauthorizeError {
            throw NAError.auth(.loginCredentialMismatch)
        }
    }
    
    func getCookies() -> [HTTPCookie] {
        // デモ用なのでCookieは不要
        return []
    }
    
    func clearAuthentication() throws {}
}
