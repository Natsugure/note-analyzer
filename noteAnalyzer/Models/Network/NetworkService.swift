//
//  NetworkManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/08.
//

import SwiftUI
import WebKit

protocol NetworkServiceProtocol {
    func fetchData(url: String) async throws -> Data
    func resetWebComponents()
}

class NetworkService: NetworkServiceProtocol {
    private let authManager: AuthenticationProtocol
    
    private var isLastPage = false
    private var isUpdated = false
    private var session: URLSession
    
    // レート制限のための変数
    private let requestsPerMinute: Int = 60
    private var requestTimestamps: [Date] = []
    
    init(authManager: AuthenticationProtocol) {
        self.authManager = authManager
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchData(url urlString: String) async throws -> Data {
        print(urlString)

        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL: \(urlString)")
        }
        
        try await checkRateLimit()
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = nil
        request.cachePolicy = .reloadIgnoringLocalCacheData
        try addCookiesToRequest(&request)
        
        let (data, _) = try await session.data(for: request)
        
        requestTimestamps.append(Date())
        
        return data
    }
    
    private func addCookiesToRequest(_ request: inout URLRequest) throws {
        let cookies = authManager.getCookies()
        
        if cookies.isEmpty {
            throw NAError.auth(.authCookiesNotFound)
        }
        
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        if let headers = request.allHTTPHeaderFields {
            request.allHTTPHeaderFields = headers.merging(cookieHeaders) { (_, new) in new }
        } else {
            request.allHTTPHeaderFields = cookieHeaders
        }
    }
    
    ///URLSession、WKWebViewから関連するデータを全て削除して再定義。
    func resetWebComponents() {
        // HTTPCookieStorageからクッキーを削除
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        // URLSessionをリセットして、URLSessionConfigurationを再定義
        URLSession.shared.reset {
            DispatchQueue.main.async {
                let configuration = URLSessionConfiguration.ephemeral
                configuration.httpShouldSetCookies = true
                configuration.httpCookieAcceptPolicy = .always
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // キャッシュを無視
                self.session = URLSession(configuration: configuration)
            }
        }
        
        // WebViewのCookieとキャッシュをクリア
        WKProcessPool.shared.reset()
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                print("WebView cookies cleared")
            }
        }
    }
    
    // レート制限をチェックし、必要に応じて待機する関数
    private func checkRateLimit() async throws {
        let now = Date()
        // 1分以上前のタイムスタンプを削除
        requestTimestamps = requestTimestamps.filter { now.timeIntervalSince($0) < 60 }
        
        if requestTimestamps.count >= requestsPerMinute {
            // 最も古いリクエストから60秒経過するまで待機
            let oldestTimestamp = requestTimestamps[0]
            let waitTime = 60 - now.timeIntervalSince(oldestTimestamp)
            if waitTime > 0 {
                print("レート制限に達しました。\(waitTime)秒待機します。")
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
    }
}

extension WKProcessPool {
   static var shared = WKProcessPool()

   func reset(){
       WKProcessPool.shared = WKProcessPool()
   }
}
