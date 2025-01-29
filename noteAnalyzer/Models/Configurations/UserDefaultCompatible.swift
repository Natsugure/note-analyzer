//
//  UserDefaultsCompatible.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/08.
//

import Foundation

protocol UserDefaultCompatible {
    init?(with object: Any)
    func object() -> Any?
}

extension UserDefaultCompatible where Self: Codable {
    init?(with object: Any) {
        guard let data = object as? Data else { return nil }
        
        do {
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
    
    func object() -> Any? {
        try? JSONEncoder().encode(self)
    }
}

extension Int: UserDefaultCompatible {}
extension Double: UserDefaultCompatible {}
extension Float: UserDefaultCompatible {}
extension Bool: UserDefaultCompatible {}
extension String: UserDefaultCompatible {}
extension Date: UserDefaultCompatible {}
extension Data: UserDefaultCompatible {}
