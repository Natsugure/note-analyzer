//
//  KeychainManager.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/07/17.
//

import Foundation
import Security

class AuthenticationManager {
    private var cookies: [HTTPCookie] = []
    
    init() {
        cookies = loadCookiesFromKeychain()
    }
    
    func saveAuthCookies(cookies: [HTTPCookie]) throws {
        let noteCookies = cookies.filter { $0.domain.contains("note.com") }
        if !noteCookies.isEmpty {
            try saveCookiesToKeychain(cookies: noteCookies)
            print("認証成功: \(noteCookies.count) cookies found")
            self.cookies = noteCookies
            
        } else {
            print("認証失敗: No note.com cookies found")
            
            throw NAError.auth(.authCookiesNotFound)
        }
    }
    
    private func loadCookiesFromKeychain() -> [HTTPCookie] {
        if let cookieData = try? KeychainManager.load(forKey: "noteCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData) as? [HTTPCookie] {
            print("Cookies load successfully, count: \(cookies.count)")
            return cookies
        }
        
        return []
    }
    
    private func saveCookiesToKeychain(cookies: [HTTPCookie]) throws {
        if let cookieData = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: true) {
            try KeychainManager.save(cookieData: cookieData, forKey: "noteCookies")
        }
    }
    
    private func deleteKeychainItem(forKey key: String) throws {
        try KeychainManager.delete(forKey: key)
    }
    
    func getCookies() -> [HTTPCookie] {
        return cookies
    }
    
    func clearAuthentication() throws {
        try deleteKeychainItem(forKey: "noteCookies")
        cookies.removeAll()
        
        print("Keychain delete successful")
    }
}

class KeychainManager {
    static func save(cookieData: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: cookieData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }
    
    static func load(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                print("Keychain item not found for key: \(key) (This might be normal)")
            } else {
                print("Keychain load failed for key: \(key), status: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            }
            
            throw KeychainError(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    static func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        // 削除時にアイテムが見つからないことは特に問題がないため、正常系として扱う。
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }
}

enum KeychainError: LocalizedError {
    case duplicateItem
    case itemNotFound
    case invalidData
    case authFailed
    case unhandledError(OSStatus)
    
    init(status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .duplicateItem
        case errSecItemNotFound:
            self = .itemNotFound
        case errSecInvalidData:
            self = .invalidData
        case errSecAuthFailed:
            self = .authFailed
        default:
            self = .unhandledError(status)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .duplicateItem:
            return "アイテムが既に存在しています"
        case .itemNotFound:
            return "アイテムが見つかりませんでした"
        case .invalidData:
            return "不正なデータです"
        case .authFailed:
            return "認証に失敗しました"
        case .unhandledError(let status):
            return "予期せぬエラーが発生しました: \(status)"
        }
    }
}
