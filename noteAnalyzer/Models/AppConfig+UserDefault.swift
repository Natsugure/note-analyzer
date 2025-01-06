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
    private let defaultValue: T
    
    init(key: Key, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
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
    
    /// `UserDefaults.standard.object(forKey:)`で自身のkeyを検索し、値が存在しているかどうかを`Bool`値で返す。
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
    
    static func removeObject<T>(for object: UserDefault<T>) {
        UserDefaults.standard.removeObject(forKey: object.key.rawValue)
    }
    
    static func deleteUserInfo() {
        let keys: [String] = [
            AppConfig.$contentsCount.key.rawValue,
            AppConfig.$lastCalculateAt.key.rawValue,
            AppConfig.$urlname.key.rawValue
        ]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
