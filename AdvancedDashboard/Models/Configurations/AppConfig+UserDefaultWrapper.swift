//
//  AppConfig+UserDefaultWrapper.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2024/12/22.
//

import Foundation

@propertyWrapper
struct UserDefaultWrapper<T: UserDefaultCompatible> {
    let key: UserDefaultsKey
    private let defaultValue: T
    
    init(key: UserDefaultsKey, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        
//        migrateToDataObject(key: key)
    }
    
    var wrappedValue: T {
        get {
            if let object = UserDefaults.standard.object(forKey: key.rawValue) {
                if let value = T(with: object) {
                    return value
                } else {
                    UserDefaultsMigrator.migrateIfNeeded()
                }
            } else {
                return self.defaultValue
            }
            
        } set {
            if let object = newValue.object() {
                UserDefaults.standard.set(object, forKey: key.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: key.rawValue)
            }
        }
        
//        get {
//            return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
//        }
//        
//        set {
//            UserDefaults.standard.set(newValue, forKey: key.rawValue)
//        }
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
    /// v1.0.0で`Data`型にエンコードせずにUserDefaultsに格納していた型を、`Data`型に変換して格納し直すマイグレーションメソッド。
    private func migrateToDataObject(key: UserDefaultsKey) {

    }
}

enum UserDefaultsKey: String, CaseIterable {
    case authenticationConfigured
    case contentsCount
    case lastCalculateAt
    case urlname
    case userId
    case sortOrder
    
    // UserDefaultsのマイグレーション済みフラグ
    case userDefaultsMigrationToDataFormatCompleted
    
    // 以下はデバッグビルド専用のUserDefaultsKeyを置く
    case demoModeKey
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
    
    @UserDefaultWrapper(key: .sortOrder, defaultValue: .viewDecending)
    static var sortOrder: SortType
    
    @UserDefaultWrapper(key: .userDefaultsMigrationToDataFormatCompleted, defaultValue: false)
    static var userDefaultsMigrationToDataFormatCompleted: Bool
    
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

struct UserDefaultsMigrator {
    static func migrateIfNeeded() {
        if AppConfig.userDefaultsMigrationToDataFormatCompleted {
            return
        }
        
        migrateAllKeys()
        
        AppConfig.userDefaultsMigrationToDataFormatCompleted = true
    }
    
    static func migrate<T: UserDefaultCompatible>(object: T) -> T {
        
    }
    
    private static func migrateAllKeys() {
        UserDefaultsKey.allCases.forEach { migrateKeyToDataFormat($0) }
    }
    
    private static func migrateKeyToDataFormat(_ key: UserDefaultsKey) {
        // すでにUserDefaultsに値が存在する場合のみマイグレーションを試みる
        if let storedObject = UserDefaults.standard.object(forKey: key.rawValue) {
            // storedObjectがすでにData型で、かつT型にデコード可能なら何もしない
            if let data = storedObject as? Data, T(with: data) != nil {
                print("No migration needed for \(key.rawValue): already in Data format")
                return
            }
            
            // 直接T型にキャスト可能なら、それをエンコードしてData型として保存し直す
            if let directCast = storedObject as? T,
               let encodedObject = directCast.object() {
                UserDefaults.standard.set(encodedObject, forKey: key.rawValue)
                print("Migration succeeded for \(key.rawValue): converted to Data format")
            } else {
                // マイグレーション失敗時は値をクリアする
                UserDefaults.standard.removeObject(forKey: key.rawValue)
                print("Warning: Migration failed for \(key.rawValue). Using default value.")
            }
        }
    }
}
