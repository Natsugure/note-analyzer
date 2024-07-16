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
    var isLastPage = false
    
    
    var stringCookie: String = "_note_session_v5=34a6711d7e5ec15354d349afc5a879cd; XSRF-TOKEN=qD6vLdnL1Ai8jFfSHeO8plSxBysZjpf9xMBxJGYV5TU;fp=0e9df89b0f721197676b8693faa2f5b3b; _vid_v1=62e92e11be374b0e94b8aedaeea6bab4; _vid_v1=62e92e11be374b0e94b8aedaeea6bab4"
    
    func fetchData(url urlString: String) async {
//        var isLastPage: Bool = false
//        var pageCount: Int = 1
//        let statsURLString = "https://note.com/api/v1/stats/pv?filter=all&page=\(String(pageCount))&sort=pv"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(stringCookie, forHTTPHeaderField: "Cookie")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let e = error {
                print(e.localizedDescription)
            } else if let data = data {
                self.parseJSON(data: data)
            }
        }
        task.resume()
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        //Cookieの取得はできているけど、このCookieをURLRequestに入れるだけではログインできないみたい。
        //Vivaldiでログイン状態のCookieをそのままStringにぶち込んだらstatsのJSON出せた。WKWebViewから取得したCookieがなにか間違っているっぽい。
        do {
            let results = try decoder.decode(Results.self, from: data)
            DispatchQueue.main.async {
                self.contents += results.data.note_stats
                self.isLastPage = results.data.last_page
//                print(self.contents)
            }
        } catch {
            print(error)
        }
    }
    
    func getStats() async {
        var page: Int = 1
        while true {
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(String(page))&sort=pv"
            await fetchData(url: urlString)
            print("ループ\(page)回目：\(isLastPage)")
            if isLastPage {
                print("抜けたよ")
                break
            }
            print("-----------\(page)------------")
            page += 1
            sleep(2)
        }
    }
    
    func getCookies(_ webView: WKWebView) {
        //        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { (cookies) in
        //            for eachCookie in cookies {
        //                if eachCookie.domain.contains(".note.com") {
        //                    print("引っかかった")
        //                    self.stringCookie += "\(eachCookie.name) = \(eachCookie.value);"
        //                }
        //            }
        //        }
        
//        fetchData()
    }
    
}
