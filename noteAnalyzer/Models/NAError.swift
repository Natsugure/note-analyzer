//
//  ErrorEnum.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/13.
//

import Foundation

enum NAError: LocalizedError {
    enum Network: LocalizedError {
        case statsNotUpdated //API上のstatsデータがまだ更新されていない
        case unknownNetworkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .statsNotUpdated:
                return "前回の取得以降、まだ統計が更新されていません。\n 時間が経ってから再度お試しください。"
            case .unknownNetworkError(let error):
                return "不明なエラーが発生しました。\n\(error)"
            }
        }
    }
    
    enum Auth: LocalizedError {
        case authenticationFailed
        case loginCredentialMismatch
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed:
                return "noteへのログインに失敗しました。"
            case .loginCredentialMismatch:
                return "保存済みの認証情報と、今回入力された認証情報が一致しません。"
            }
        }
    }
    
    enum Decoding: LocalizedError {
        case decodingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .decodingFailed:
                return "JSONのデコーディングに失敗"
            }
        }
    }
    
    enum Realm: LocalizedError {
        
        var errorDescription: String? {
            switch self {
                
            }
        }
    }
    
    case network(_ detail: Network)
    case auth(_ detail: Auth)
    case decoding(_ detail: Decoding)
    case realm(_ detail: Realm)

    var errorDescription: String? {
        switch self {
        case .network(let detail):
            return detail.errorDescription
        case .auth(let detail):
            return detail.errorDescription
        case .decoding(let detail):
            return detail.errorDescription
        case .realm(let detail):
            return detail.errorDescription
        }
    }
}
