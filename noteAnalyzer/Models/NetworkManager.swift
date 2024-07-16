//
//  NetworkManager.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/08.
//

import Foundation
import WebKit

class NetworkManager: ObservableObject {
    
    @Published var contents = [Contents]()
    private var isLastPage = false
    
    private var stringCookie: String = ""
//    private var stringCookie: String = "_note_session_v5=34a6711d7e5ec15354d349afc5a879cd; XSRF-TOKEN=qD6vLdnL1Ai8jFfSHeO8plSxBysZjpf9xMBxJGYV5TU;fp=0e9df89b0f721197676b8693faa2f5b3b; _vid_v1=62e92e11be374b0e94b8aedaeea6bab4; _vid_v1=62e92e11be374b0e94b8aedaeea6bab4"
    
    // レート制限のための変数
    private let requestsPerMinute: Int = 60 // 1分あたりの最大リクエスト数
    private var requestTimestamps: [Date] = [] // リクエストのタイムスタンプを格納する配列
    
    private func fetchData(url urlString: String) async throws {
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // レート制限をチェック
        try await checkRateLimit()
        
        var request = URLRequest(url: url)
        request.setValue(stringCookie, forHTTPHeaderField: "Cookie")
        //Cookieの取得はできているけど、このCookieをURLRequestに入れるだけではログインできないみたい。
        //Vivaldiでログイン状態のCookieをそのままStringにぶち込んだらstatsのJSON出せた。WKWebViewから取得したCookieがなにか間違っているっぽい。
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let results = try decoder.decode(Results.self, from: data)
        
        await MainActor.run {
            self.contents += results.data.note_stats
            self.isLastPage = results.data.last_page
        }
        
        // リクエストのタイムスタンプを記録
        requestTimestamps.append(Date())
    }
    
    func getStats() async {
        let maxLoopCount = 60
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            
            do {
                try await fetchData(url: urlString)

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
        print("取得完了, 総アイテム数: \(contents.count)")
    }
    
    func getCookies(_ webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { (cookies) in
            for eachCookie in cookies {
                if eachCookie.domain.contains(".note.com") {
                    print("引っかかった")
                    self.stringCookie += "\(eachCookie.name)=\(eachCookie.value); "
                    print(self.stringCookie)
                }
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
