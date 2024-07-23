//
//  NetworkManager.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/08.
//

import SwiftUI
import WebKit

class NetworkManager: ObservableObject {
    
    @Published var contents = [FetchedStatsData.Content]()
    @Published var publishedDateArray = [FetchedContentsData.Content]()
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    private var isLastPage = false
    private var isUpdated = false
    private let session: URLSession
    private var cookies: [HTTPCookie] = []
    
    private let realmManager: RealmManager
    
    // レート制限のための変数
    private let requestsPerMinute: Int = 60 // 1分あたりの最大リクエスト数
    private var requestTimestamps: [Date] = [] // リクエストのタイムスタンプを格納する配列
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        self.session = URLSession(configuration: configuration)
        
        if let cookieData = KeychainManager.load(forKey: "noteCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData) as? [HTTPCookie] {
            self.cookies = cookies
        }
        
        do {
            self.realmManager = try RealmManager()
        } catch {
            fatalError("Failed to initialize RealmManager: \(error)")
        }
    }
    
    func authenticate() {
        showAuthWebView = true
    }
    
    func checkAuthentication(webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let noteCookies = cookies.filter { $0.domain.contains("note.com") }
            self.isAuthenticated = !noteCookies.isEmpty
            if self.isAuthenticated {
                self.cookies = noteCookies
                let cookieData = try? NSKeyedArchiver.archivedData(withRootObject: noteCookies, requiringSecureCoding: true)
                if let data = cookieData {
                    let status = KeychainManager.save(cookieData: data, forKey: "noteCookies")
                    print("Keychain save status: \(status)")
                }
                print("認証成功: \(noteCookies.count) cookies found")
                self.showAuthWebView = false
            } else {
                print("認証失敗: No note.com cookies found")
            }
        }
    }
    
    //inoutは参照渡しを意味する。関数内で引数の値を変更しても、元の変数の値も変わる。
    private func addCookiesToRequest(_ request: inout URLRequest) {
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        request.allHTTPHeaderFields = cookieHeaders
    }
    
    private func fetchData(url urlString: String) async throws -> Data {
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // レート制限をチェック
        try await checkRateLimit()
        
        var request = URLRequest(url: url)
        addCookiesToRequest(&request)
        
        let (data, _) = try await session.data(for: request)
        
        return data
    }
    
    private func parseStatsJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode(FetchedStatsData.self, from: data)
        
        await MainActor.run {
            let thisTime = self.stringToDate(results.data.lastCalculateAt)
            let lastTime = self.stringToDate(UserDefaults.standard.string(forKey: "lastCalculateAt")!)
            
            if thisTime <= lastTime {
                self.isUpdated = false
                return
            } else {
                self.isUpdated = true
                self.contents += results.data.noteStats
                self.isLastPage = results.data.lastPage
                
                if self.isLastPage {
                    UserDefaults.standard.set(results.data.lastCalculateAt, forKey: "lastCalculateAt")
                }
            }
        }
        
        // リクエストのタイムスタンプを記録
        requestTimestamps.append(Date())
    }
    
    private func parseContentsJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode(FetchedContentsData.self, from: data)
        
        await MainActor.run {
            self.publishedDateArray += results.data.contents
            self.isLastPage = results.data.isLastPage
        }
        
        // リクエストのタイムスタンプを記録
        requestTimestamps.append(Date())
    }
    
    func getStats() async {
        let maxLoopCount = 100
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            
            do {
                let fetchedData = try await fetchData(url: urlString)
                try await parseStatsJSON(fetchedData)
                
                if page == 1 && !isUpdated {
                    print("更新されていません")
                    break
                }
                
                if isLastPage {
                    print("最後のページに到達しました - 総ページ数: \(page)")
                    break
                }
                
                // リクエスト間に1秒の遅延を追加
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                print("Error: \(error)")
                break
            }
        }

        if isUpdated {
            print("取得完了, 総アイテム数: \(contents.count)")
            
            await getPublishedDate()
            
            await MainActor.run {
                realmManager.updateStats(stats: contents, publishedDate: publishedDateArray)
            }
        }
        
        isUpdated = false
    }
    
    func getPublishedDate() async {
        let maxLoopCount = 200
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v2/creators/natsu_gure/contents?kind=note&page=\(page)"
            
            do {
                let fetchedData = try await fetchData(url: urlString)
                try await parseContentsJSON(fetchedData)
                
                if isLastPage {
                    print("最後のページに到達しました - 総ページ数: \(page)")
                    break
                }
                
                // リクエスト間に1秒の遅延を追加
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                print("Error: \(error)")
                break
            }
        }
        print("取得完了, 総アイテム数: \(publishedDateArray.count)")
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
    
    func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
}
