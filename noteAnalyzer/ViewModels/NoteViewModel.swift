//
//  ViewModels.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/08/17.
//

import SwiftUI
import WebKit

class NoteViewModel: ObservableObject {
    @Published var contents = [APIStatsResponse.APIStatsItem]()
    @Published var publishedDateArray = [APIContentsResponse.APIContentItem]()
    @Published var isAuthenticated = false
    @Published var showAuthWebView = false
    
    private let authManager: AuthenticationManager
    private let networkService: NetworkService
    private let realmManager: RealmManager
    
    private var isLastPage = false
    private var isUpdated = false
    
    init(authManager: AuthenticationManager, networkService: NetworkService, realmManager: RealmManager) {
        self.networkService = networkService
        self.realmManager = realmManager
        self.authManager = authManager
        
        // AuthenticationManagerの状態をViewModelの状態に反映
        authManager.$isAuthenticated.assign(to: &$isAuthenticated)
        authManager.$showAuthWebView.assign(to: &$showAuthWebView)
    }
    
    func authenticate() {
        authManager.authenticate()
    }
    
    func checkAuthentication(webView: WKWebView) {
        authManager.checkAuthentication(webView: webView)
    }
    
    func getStats() async {
        let maxLoopCount = 100
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=\(page)&sort=pv"
            
            do {
                let fetchedData = try await networkService.fetchData(url: urlString)
                try await parseStatsJSON(fetchedData)
                
                if page == 1 && !isUpdated {
                    print("更新されていません")
                    break
                }
                
                if isLastPage {
                    print("最後のページに到達しました - 総ページ数: \(page)")
                    break
                }
                
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode(APIStatsResponse.self, from: data)
        
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
    
    func getPublishedDate() async {
        let maxLoopCount = 200
        let urlName = UserDefaults.standard.string(forKey: "urlname") ?? "（不明なユーザー名）"
        for page in 1...maxLoopCount {
            let urlString = "https://note.com/api/v2/creators/\(urlName)/contents?kind=note&page=\(page)"
            
            do {
                let fetchedData = try await networkService.fetchData(url: urlString)
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
    
    private func parseContentsJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let results = try decoder.decode(APIContentsResponse.self, from: data)
        
        await MainActor.run {
            self.publishedDateArray += results.data.contents
            self.isLastPage = results.data.isLastPage
        }
    }

    func clearAllData() async {
        await MainActor.run {
            do {
                try realmManager.deleteAll()
                authManager.clearAuthentication()
            } catch {
                print("Failed to delete all data: \(error)")
            }
            
            UserDefaults.standard.set("1970/1/1 00:00", forKey: "lastCalculateAt")
            UserDefaults.standard.set("", forKey: "urlname")
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