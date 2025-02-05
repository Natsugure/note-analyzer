//
//  AppConfig+UserDefaultWrapper.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/12/22.
//

import Foundation

@propertyWrapper
struct UserDefaultWrapper<T: UserDefaultCompatible> {
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
    var isSetValue: Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
}

extension UserDefaultWrapper {
    enum Key: String {
        case authenticationConfigured
        case contentsCount
        case lastCalculateAt
        case urlname
        case userId
        
        case demoModeKey
    }
}

struct AppConfig {
    @UserDefaultWrapper(key: .authenticationConfigured, defaultValue: false)
    static var isCompletedInitialSetup: Bool
    
    @UserDefaultWrapper(key: .contentsCount, defaultValue: 0)
    static var contentsCount: Int
    
    @UserDefaultWrapper(key: .lastCalculateAt, defaultValue: "1970/1/1 00:00")
    static var lastCalculateAt: String
    
    @UserDefaultWrapper(key: .urlname, defaultValue: "（不明なユーザー名）")
    static var urlname: String
    
    @UserDefaultWrapper(key: .userId, defaultValue: 0)
    static var userId: Int
    
#if DEBUG
    @UserDefaultWrapper(key: .demoModeKey, defaultValue: true)
    static var isDemoMode: Bool
#endif
    
    static func removeObject<T>(for object: UserDefaultWrapper<T>) {
        UserDefaults.standard.removeObject(forKey: object.key.rawValue)
    }
    
    static func deleteUserInfo() {
        let keys: [String] = [
            AppConfig.$contentsCount.key.rawValue,
            AppConfig.$lastCalculateAt.key.rawValue,
            AppConfig.$urlname.key.rawValue,
            AppConfig.$userId.key.rawValue
        ]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
