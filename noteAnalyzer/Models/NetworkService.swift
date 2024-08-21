//
//  NetworkManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/08.
//

import SwiftUI
import WebKit

class NetworkService: ObservableObject {
    private let realmManager: RealmManager
    private let authManager: AuthenticationManager
    
//    @Published var contents = [APIStatsResponse.APIStatsItem]()
//    @Published var publishedDateArray = [APIContentsResponse.APIContentItem]()
//    @Published var isAuthenticated = false
//    @Published var showAuthWebView = false
    
    private var isLastPage = false
    private var isUpdated = false
    private var session: URLSession
    private var cookies: [HTTPCookie] = []
    
    // レート制限のための変数
    private let requestsPerMinute: Int = 60 // 1分あたりの最大リクエスト数
    private var requestTimestamps: [Date] = [] // リクエストのタイムスタンプを格納する配列
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        self.realmManager = RealmManager()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData // キャッシュを無視
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchData(url urlString: String) async throws -> Data {
        print(urlString)

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // レート制限をチェック
        try await checkRateLimit()
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = nil
        request.cachePolicy = .reloadIgnoringLocalCacheData // キャッシュを無視
        addCookiesToRequest(&request)
        
        let (data, _) = try await session.data(for: request)
        
        // リクエストのタイムスタンプを記録
        requestTimestamps.append(Date())
        
        return data
    }
    
    private func addCookiesToRequest(_ request: inout URLRequest) {
        let cookies = authManager.getCookies()
        
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        if let headers = request.allHTTPHeaderFields {
            request.allHTTPHeaderFields = headers.merging(cookieHeaders) { (_, new) in new }
        } else {
            request.allHTTPHeaderFields = cookieHeaders
        }
    }
    
    //URLSession、WKWebViewから関連するデータを全て削除して再定義。
    func resetWebComponents() {
        // HTTPCookieStorageからクッキーを削除
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                print("before delete: \(cookie)")
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        cookies.removeAll()
        
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
    
    private func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
}

extension WKProcessPool {
   static var shared = WKProcessPool()

   func reset(){
       WKProcessPool.shared = WKProcessPool()
   }
}
