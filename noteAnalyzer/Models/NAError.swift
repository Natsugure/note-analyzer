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
    
    case network(_ detail: Network)
    case auth(_ detail: Auth)

    var errorDescription: String? {
        switch self {
        case .network(let detail):
            return detail.errorDescription
        case .auth(let detail):
            return detail.errorDescription
        }
    }
}
