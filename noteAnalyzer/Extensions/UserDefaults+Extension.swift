//
//  UserDefaults.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/12/22.
//

import Foundation

protocol UserDefaultConvertible {
    init?(with object: Any)
    func object() -> Any?
}

@propertyWrapper
struct UserDefault<Value: UserDefaultConvertible> {
    let key: String
    let defaultValue: Value
    
    init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            if let object = UserDefaults.standard.object(forKey: self.key),
               let value = Value(with: object) 
            {
                return value
            } else {
                return self.defaultValue
            }
        }
        
        set {
            if let object = newValue.object() {
                UserDefaults.standard.set(object, forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
        }
    }
}

extension Int: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Int else {
            return nil
        }
        self = value
    }
    
    func object() -> Any? {
        return self
    }
}

extension String: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? String else {
            return nil
        }
        self = value
    }
    
    func object() -> Any? {
        return self
    }
}

extension Bool: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Bool else {
            return nil
        }
        self = value
    }
    
    func object() -> Any? {
        return self
    }
}
