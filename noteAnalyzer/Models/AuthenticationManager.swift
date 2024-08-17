//
//  KeychainManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/17.
//

import SwiftUI
import WebKit
import Security
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    private var cookies: [HTTPCookie] = []
    
    init() {
        loadCookiesFromKeychain()
    }
    
    func authenticate() {
        showAuthWebView = true
    }
    
    func checkAuthentication(webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            let noteCookies = cookies.filter { $0.domain.contains("note.com") }
            self.isAuthenticated = !noteCookies.isEmpty
            if self.isAuthenticated {
                self.cookies = noteCookies
                self.saveCookiesToKeychain()
                print("認証成功: \(noteCookies.count) cookies found")
                self.showAuthWebView = false
            } else {
                print("認証失敗: No note.com cookies found")
            }
        }
    }
    
    private func loadCookiesFromKeychain() {
        if let cookieData = KeychainManager.load(forKey: "noteCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData) as? [HTTPCookie] {
            print("Cookies load successfully, count: \(cookies.count)")
            self.cookies = cookies
            self.isAuthenticated = !cookies.isEmpty
        }
        print("isAuthenticated: \(isAuthenticated)")
    }
    
    private func saveCookiesToKeychain() {
        if let cookieData = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: true) {
            let status = KeychainManager.save(cookieData: cookieData, forKey: "noteCookies")
            print("Keychain save status: \(status)")
        }
    }
    
    func getCookies() -> [HTTPCookie] {
        return cookies
    }
    
    func clearAuthentication() {
        cookies.removeAll()
        isAuthenticated = false
        
        let status = KeychainManager.delete(forKey: "noteCookies")
        if status == errSecSuccess {
            print("Keychain delete successful")
        } else {
            print("Keychain delete failed with status: \(status)")
        }
    }
}

class KeychainManager {
    static func save(cookieData: Data, forKey key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: cookieData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return (status == errSecSuccess) ? (result as? Data) : nil
    }
    
    static func delete(forKey key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        return SecItemDelete(query as CFDictionary)
    }
}
