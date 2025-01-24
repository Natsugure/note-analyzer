//
//  KeychainManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/17.
//

import SwiftUI
import Security

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case unhandledError(Error)
}

//protocol AuthenticationProtocol {
//    func saveAuthCookies(cookies: [HTTPCookie]) throws
//    func getCookies() -> [HTTPCookie]
//    func clearAuthentication() throws
//}

class AuthenticationManager {
    private var cookies: [HTTPCookie] = []
    
    init() {
        cookies = loadCookiesFromKeychain()
    }
    
    func saveAuthCookies(cookies: [HTTPCookie]) throws {
        let noteCookies = cookies.filter { $0.domain.contains("note.com") }
        if !noteCookies.isEmpty {
            self.saveCookiesToKeychain(cookies: noteCookies)
            print("認証成功: \(noteCookies.count) cookies found")
            self.cookies = noteCookies
            
        } else {
            print("認証失敗: No note.com cookies found")
            
            throw NAError.auth(.authCookiesNotFound)
        }
    }
    
    private func loadCookiesFromKeychain() -> [HTTPCookie] {
        if let cookieData = KeychainManager.load(forKey: "noteCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData) as? [HTTPCookie] {
            self.cookies = cookies
            
            print("Cookies load successfully, count: \(cookies.count)")
            
            return cookies
        }
        
        return []
    }
    
    private func saveCookiesToKeychain(cookies: [HTTPCookie]) {
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
    
    func getCookies() -> [HTTPCookie] {
        return cookies
    }
    
    func clearAuthentication() throws {
        do {
            try deleteKeychainItem(forKey: "noteCookies")
            self.cookies.removeAll()
            
            print("Keychain delete successful")
            
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
