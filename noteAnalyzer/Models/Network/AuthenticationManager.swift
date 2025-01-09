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

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case unhandledError(Error)
}

protocol AuthenticationProtocol {
//    var isAuthenticated: Bool { get set }
    var showAuthWebView: Bool { get set }
    
    func authenticate()
    func isValidAuthCookies(cookies: [HTTPCookie]) -> Bool
    func getCookies() throws -> [HTTPCookie]
    func clearAuthentication() throws
}

class AuthenticationManager: ObservableObject, AuthenticationProtocol {
//    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    private var cookies: [HTTPCookie] = []
    
//    init() {
//        // TODO: Cookieのチェックタイミングを変えて、見つからないときにloadCookiesFromKeyChain()からエラーを投げられるようにすべき。
//        // イニシャライザでチェックしてると初回起動時と挙動を変えられないから。
////        isAuthenticated = !loadCookiesFromKeychain().isEmpty
//    }
    
    func authenticate() {
        showAuthWebView = true
    }
    
    func isValidAuthCookies(cookies: [HTTPCookie]) -> Bool {
        let noteCookies = cookies.filter { $0.domain.contains("note.com") }
        if !noteCookies.isEmpty {
//            self.isAuthenticated = true
//            self.cookies = noteCookies
            self.saveCookiesToKeychain()
            print("認証成功: \(noteCookies.count) cookies found")
            self.showAuthWebView = false
            
            return true
        } else {
//            self.isAuthenticated = false
            // TODO: ここでエラーをthrowする方法を考える
            print("認証失敗: No note.com cookies found")
            
            return false
        }
    }
    
    private func loadCookiesFromKeychain() throws -> [HTTPCookie] {
        if let cookieData = KeychainManager.load(forKey: "noteCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData) as? [HTTPCookie] {
            print("Cookies load successfully, count: \(cookies.count)")
            self.cookies = cookies
//            self.isAuthenticated = !cookies.isEmpty
            
            return cookies
        }
        
        throw NAError.auth(.authCookiesNotFound)
    }
    
    private func saveCookiesToKeychain() {
        if let cookieData = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: true) {
            let status = KeychainManager.save(cookieData: cookieData, forKey: "noteCookies")
            print("Keychain save status: \(status)")
        }
    }
    
    private func deleteKeychainItem(forKey key: String) throws {
        let status = KeychainManager.delete(forKey: key)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func getCookies() throws -> [HTTPCookie] {
        try loadCookiesFromKeychain()
    }
    
    func clearAuthentication() throws {
        cookies.removeAll()
        
        do {
            try deleteKeychainItem(forKey: "noteCookies")
            print("Keychain delete successful")
//            isAuthenticated = false
        } catch KeychainError.unexpectedStatus(let status) {
            handleKeychainError(status: status)
            throw KeychainError.unexpectedStatus(status)
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
            throw KeychainError.unhandledError(error)
        }
    }
    
    private func handleKeychainError(status: OSStatus) {
        switch status {
        case errSecItemNotFound:
            print("Keychain item not found. It may have been already deleted.")
        case errSecDuplicateItem:
            print("Duplicate item found in Keychain.")
        case errSecAuthFailed:
            print("Authentication failed. Check Keychain access permissions.")
        default:
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
