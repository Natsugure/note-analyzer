//
//  ViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/17.
//

import SwiftUI
import WebKit

class ViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    @Published var progressValue = 0.0
    
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    private let apiFetcher: NoteAPIFetcher
    let realmManager: RealmManager
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol, realmManager: RealmManager, apiFetcher: NoteAPIFetcher) {
        self.networkService = networkService
        self.realmManager = realmManager
        self.authManager = authManager
        self.apiFetcher = apiFetcher
        
        // AuthenticationManagerの状態をViewModelの状態に反映
        if let authManager = authManager as? AuthenticationManager {
//            authManager.$isAuthenticated.assign(to: &$isAuthenticated)
//            authManager.$showAuthWebView.assign(to: &$showAuthWebView)
            print("Normal ViewModel initialized")
        } else if let mockAuthManager = authManager as? MockAuthenticationManager {
//            mockAuthManager.$isAuthenticated.assign(to: &$isAuthenticated)
//            mockAuthManager.$showAuthWebView.assign(to: &$showAuthWebView)
        }
        
        apiFetcher.$progressValue.assign(to: &$progressValue)
    }
    
//    func authenticate() {
//        authManager.authenticate()
//    }
//    
//    func checkAuthentication(cookies: [HTTPCookie]) {
//        authManager.isValidAuthCookies(cookies: cookies)
//    }
    
    func getStats() async throws {
        let (stats, publishedDateArray) = try await apiFetcher.getStats()
        
        try await MainActor.run {
            // TODO: DB書き込み処理のprogressValueはどう計算するか？コンテンツ数が少ないなら一瞬だが、1000記事を超えるような人だとどうか？
            // TODO: RealmManager内のエラー処理が定まっていないので、RealmManager内で定義する。
            try realmManager.updateStats(stats: stats, publishedDate: publishedDateArray)
        }
    }
    
    func verifyLoginConsistency() async throws {
//        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
//        
//        do {
//            let realmItems = try realmManager.getItemList()
//            if realmItems.isEmpty {
//                return
//            }
//            
//            let fetchedData = try await networkService.fetchData(url: urlString)
//            
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            let results = try decoder.decode(APIStatsResponse.self, from: fetchedData)
//            
//            let firstArticle = results.data.noteStats[0]
//            guard let _ = realmItems.first(where: { $0.id == firstArticle.id && $0.title == firstArticle.name }) else {
//                throw NAError.Auth.loginCredentialMismatch
//            }
//        } catch {
//            throw error
//        }
    }
    
    func logout() async throws {
        try await MainActor.run {
            do {
                try authManager.clearAuthentication()
                networkService.resetWebComponents()
            } catch KeychainError.unexpectedStatus(let status) {
                throw KeychainError.unexpectedStatus(status)
            } catch {
                throw error
            }
        }
    }

    func clearAllData() async throws {
        try await MainActor.run {
            do {
                try realmManager.deleteAll()
                try authManager.clearAuthentication()
                networkService.resetWebComponents()
                
                AppConfig.deleteUserInfo()
                
            } catch KeychainError.unexpectedStatus(let status) {
                print("Keychain error occurred. \n code: \(status), description: \(status.description)")
                throw KeychainError.unexpectedStatus(status)
            } catch {
                print("Failed to delete all data: \(error)")
                throw error
            }
        }
    }
}
