//
//  ViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/17.
//

import SwiftUI
import WebKit

class ViewModel: ObservableObject {
    @Published var contents = [APIStatsResponse.APIStatsItem]()
    @Published var publishedDateArray = [APIContentsResponse.APIContentItem]()
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    let realmManager: RealmManager
    
    private var isLastPage = false
    private var isUpdated = false
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol, realmManager: RealmManager) {
        self.networkService = networkService
        self.realmManager = realmManager
        self.authManager = authManager
        
        // AuthenticationManagerの状態をViewModelの状態に反映
        if let authManager = authManager as? AuthenticationManager {
            authManager.$isAuthenticated.assign(to: &$isAuthenticated)
            authManager.$showAuthWebView.assign(to: &$showAuthWebView)
            print("Normal ViewModel initialized")
        } else if let mockAuthManager = authManager as? MockAuthenticationManager {
            mockAuthManager.$isAuthenticated.assign(to: &$isAuthenticated)
            mockAuthManager.$showAuthWebView.assign(to: &$showAuthWebView)
        }
    }
    
    func authenticate() {
        authManager.authenticate()
    }
    
    func checkAuthentication(webView: WKWebView) {
        authManager.checkAuthentication(webView: webView)
    }
    
    func getStats() async throws {
        let maxLoopCount = 100
        
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            
            do {
                let fetchedData = try await networkService.fetchData(url: urlString)
                try await parseStatsJSON(fetchedData)
                
                if page == 1 && !isUpdated {
                    print("更新されていません")
                    throw NAError.network(.statsNotUpdated)
                }
                
                if isLastPage {
                    print("最後のページに到達しました - 総ページ数: \(page)")
                    break
                }
                
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch NAError.network(.statsNotUpdated) {
                throw NAError.network(.statsNotUpdated)
            } catch {
                print("Error: \(error)")
                throw NAError.network(.unknownNetworkError(error))
            }
        }
        
        if isUpdated {
            print("取得完了, 総アイテム数: \(contents.count)")
            
            try await getPublishedDate()
            
            await MainActor.run {
                do {
                    try realmManager.updateStats(stats: contents, publishedDate: publishedDateArray)
                } catch {
                    print(error)
                }
            }
        }
        
        isUpdated = false
        
        DispatchQueue.main.async {
            self.contents.removeAll()
            self.publishedDateArray.removeAll()
        }
    }
    
    private func parseStatsJSON(_ data: Data) async throws {
        let results: APIStatsResponse = try decodeAPIResponse(data)
        
        await MainActor.run {
            let thisTime = self.stringToDate(results.data.lastCalculateAt)
            let lastTime = self.stringToDate(UserDefaults.standard.string(forKey: "lastCalculateAt")!)
            
            // lastCalculateAtがUserDefaultsに保存されている値よりも古い場合、更新されていないと判断
            if thisTime <= lastTime {
                self.isUpdated = false
                return
            } else {
                self.isUpdated = true
                self.contents += results.data.noteStats
                self.isLastPage = results.data.lastPage
                
                if self.isLastPage {
                    UserDefaults.standard.set(results.data.lastCalculateAt, forKey: "lastCalculateAt")
                    UserDefaults.standard.set(self.contents[0].user.urlname, forKey: "urlname")
                }
            }
        }
    }
    
    func decodeAPIResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            // まず、APIStatsResponseとしてデコードを試みる
            return try decoder.decode(T.self, from: data)
        } catch {
            // デコードに失敗した場合、エラーレスポンスとしてデコードを試みる
            do {
                let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                if errorResponse.error.code == "auth" {
                    throw NAError.auth(.authenticationFailed)
                } else {
                    throw NAError.decoding(.decodingFailed(error))
                }
            } catch {
                // エラーレスポンスのデコードにも失敗した場合
                throw NAError.decoding(.decodingFailed(error))
            }
        }
    }
    
    private func getPublishedDate() async throws {
        let maxLoopCount = 200
        let urlName = UserDefaults.standard.string(forKey: "urlname") ?? "（不明なユーザー名）"
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v2/creators/\(urlName)/contents?kind=note&page=\(page)"
            
            let fetchedData = try await networkService.fetchData(url: urlString)
            try await parseContentsJSON(fetchedData)
            
            if isLastPage {
                print("最後のページに到達しました - 総ページ数: \(page)")
                break
            }
            
            // リクエスト間に1秒の遅延を追加
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        print("取得完了, 総アイテム数: \(publishedDateArray.count)")
    }
    
    private func parseContentsJSON(_ data: Data) async throws {
        let results: APIContentsResponse = try decodeAPIResponse(data)
        
        await MainActor.run {
            self.publishedDateArray += results.data.contents
            self.isLastPage = results.data.isLastPage
        }
    }
    
    func verifyLoginConsistency() async throws {
        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
        
        do {
            let realmItems = try realmManager.getItems()
            if realmItems.isEmpty {
                return
            }
            
            let fetchedData = try await networkService.fetchData(url: urlString)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let results = try decoder.decode(APIStatsResponse.self, from: fetchedData)
            
            let firstArticle = results.data.noteStats[0]
            guard let _ = realmItems.first(where: { $0.id == firstArticle.id && $0.title == firstArticle.name }) else {
                throw NAError.Auth.loginCredentialMismatch
            }
        } catch {
            throw error
        }
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
                
                UserDefaults.standard.set("1970/1/1 00:00", forKey: AppConstants.UserDefaults.lastCalculateAt)
                UserDefaults.standard.set("", forKey: AppConstants.UserDefaults.urlname)
            } catch KeychainError.unexpectedStatus(let status) {
                print("Keychain error occurred. \n code: \(status), description: \(status.description)")
                throw KeychainError.unexpectedStatus(status)
            } catch {
                print("Failed to delete all data: \(error)")
                throw error
            }
        }
    }
    
    private func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
}
