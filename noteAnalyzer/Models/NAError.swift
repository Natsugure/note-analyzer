//
//  ErrorEnum.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/10/13.
//

import Foundation

enum NAError: LocalizedError {
    enum Network: LocalizedError {
        case statsNotUpdated
        case networkNotConnected
        case unknownNetworkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .statsNotUpdated:
                return "前回の取得以降、まだ統計が更新されていません。\n 時間が経ってから再度お試しください。"
            case .networkNotConnected:
                return "ネットワークに接続されていません。"
            case .unknownNetworkError(let error):
                return "不明なエラーが発生しました。\n\(error)"
            }
        }
        
        var userMessage: String {
            switch self {
            case .statsNotUpdated: "前回の取得以降、まだ統計が更新されていません。\n 時間が経ってから再度お試しください。"
            case .networkNotConnected: "ネットワークに接続されていません。\n端末の接続状態をご確認ください。"
            case .unknownNetworkError(let error): "ネットワーク上で不明なエラーが発生しました。\n 時間が経ってから再度お試しください。"
            }
        }
    }
    
    enum Auth: LocalizedError {
        case authenticationFailed
        case loginCredentialMismatch
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed: "noteへのログインに失敗しました。"
            case .loginCredentialMismatch: "保存済みの認証情報と、今回入力された認証情報が一致しません。"
            }
        }
        
        var userMessage: String {
            switch self {
            case .authenticationFailed, .loginCredentialMismatch: "noteへのログインに失敗しました。\n しばらく時間をおいてから再度お試しいただくか、設定メニューから再認証してください。"
            }
        }
    }
    
    enum Decoding: LocalizedError {
        case decodingFailed(Error)
        case unexpectedDataType(Error)
        case userNotFound(String)
        case notContents
        
        var errorDescription: String? {
            switch self {
            case .decodingFailed(let error): 
                return "JSONのデコーディングに失敗しました: \(error)"
            case .unexpectedDataType(let error):
                let decodingError = error as? DecodingError
                return "予期しないデータ型です: \(decodingError.debugDescription)"
            case .userNotFound(let userName):
                return "ユーザー名: \(userName)が見つかりませんでした。"
            case .notContents:
                return "記事が一つもありません。"
            }
        }
        
        var userMessage: String {
            switch self {
            case .decodingFailed(_), .unexpectedDataType(_):
                return "取得したデータを正しく読み込めませんでした。"
            case .userNotFound(_):
                return "保存されたユーザー名と一致するデータが見つかりませんでした。"
            case .notContents:
                return "このユーザーは記事を一つも公開していません。"
            }
        }
    }
    
    enum Realm: LocalizedError {
        case publishedDateNotFound
        case realmError(Error)

        var errorDescription: String? {
            switch self {
            case .publishedDateNotFound: "投稿日データが見つかりませんでした。"
            case .realmError(let error): "データベースの書き込み中にエラーが発生しました。\(error)"
            }
        }
        
        var userMessage: String {
            switch self {
            case .publishedDateNotFound, .realmError(_): "データベース書き込み中にエラーが発生しました。"
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
    
    var userMessage: String {
        switch self {
        case .network(let detail):
            return detail.userMessage
        case .auth(let detail):
            return detail.userMessage
        case .decoding(let detail):
            return detail.userMessage
        case .realm(let detail):
            return detail.userMessage
        }
    }
}
