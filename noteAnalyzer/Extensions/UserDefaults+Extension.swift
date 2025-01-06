//
//  UserDefaults.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/12/22.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: Key
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
    
    var projectedValue: Self {
        return self
    }
    
    var isValueSet: Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
}

extension UserDefault {
    enum Key: String {
        case authenticationConfigured
        case contentsCount
        case lastCalculateAt
        case urlname
        
        case demoModeKey
    }
}

struct AppConfig {
    @UserDefault(key: .authenticationConfigured, defaultValue: false)
    static var isAuthenticationConfigured: Bool
    
    @UserDefault(key: .contentsCount, defaultValue: 0)
    static var contentsCount: Int
    
    @UserDefault(key: .lastCalculateAt, defaultValue: "1970/1/1 00:00")
    static var lastCalculateAt: String
    
    @UserDefault(key: .urlname, defaultValue: "（不明なユーザー名）")
    static var urlname: String
    
#if DEBUG
    @UserDefault(key: .demoModeKey, defaultValue: true)
    static var isDemoMode: Bool
#endif
    
    static func isExistDemoModeValue() -> Bool {
        return $isDemoMode.isValueSet
    }
}
