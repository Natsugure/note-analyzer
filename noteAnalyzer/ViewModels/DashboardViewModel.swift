//
//  DashboardViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/12.
//

import SwiftUI
import RealmSwift

enum StatsType {
    case view
    case comment
    case like
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var listData: [ListElement] = []
    @Published var selectionChartType: StatsType = .view
    @Published var isPresentedProgressView = false
    @Published var progressValue = 0.0
    
    @Published var isShowAlert = false
    @Published var alertEntity: AlertEntity?
    
    private var token: NotificationToken?
    
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    private let statsFormatter = StatsFormatter()
    
    init(apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.apiClient = apiClient
        self.realmManager = realmManager
        
        token = try! Realm().observe({ _, _ in
            self.loadData()
        })
        
        apiClient.$progressValue.assign(to: &$progressValue)
        
        loadData()
    }
    
    deinit {
        token?.invalidate()
    }
    
    func getStats() async {
        isPresentedProgressView = true

        do {
            let (stats, publishedDateArray) = try await apiClient.requestFetch()
            
            // TODO: DB書き込み処理のprogressValueはどう計算するか？コンテンツ数が少ないなら一瞬だが、1000記事を超えるような人だとどうか？
            // TODO: RealmManager内のエラー処理が定まっていないので、RealmManager内で定義する。
            try realmManager.updateStats(stats: stats, publishedDate: publishedDateArray)
            
            isPresentedProgressView = false
            
            // Task.sleepで処理に間を空けないと、ProgressViewのTransaction.disablesAnimationが機能しない。
            // Viewの更新とStateObjectのobjectWillChangeがコンフリクトすると無効になる？
            try? await Task.sleep(for: .seconds(0.1))
            
            alertEntity = .init(singleButtonAlert: "取得完了", message: "統計情報の取得が完了しました。")
            
//            alertEntity = .single(
//                title: "取得完了",
//                message: "統計情報の取得が完了しました。",
//                button: AlertEntity.AlertButton(text: "OK")
//            )
//            
//            isShowAlert = true
        } catch {
            isPresentedProgressView = false
            
            try? await Task.sleep(for: .seconds(0.1))
            handleGetStatsError(error)
        }
    }
    
    func calculateChartData() -> [(Date, Int)] {
        let stats = realmManager.getStatsResults()
        let latestStatsByDate = statsFormatter.filterLatestStatsOnDayOfAllArticles(stats: Array(stats))
        
        var result: [(Date, Int)] = []
        
        for dayStats in latestStatsByDate {
            let totalCount: Int
            switch selectionChartType {
            case .view:
                totalCount = dayStats.reduce(0) { $0 + $1.readCount }
            case .comment:
                totalCount = dayStats.reduce(0) { $0 + $1.commentCount }
            case .like:
                totalCount = dayStats.reduce(0) { $0 + $1.likeCount }
            }
            
            if let latestTime = dayStats.first?.updatedAt {
                result.append((DateUtils.calendar.startOfDay(for: latestTime), totalCount))
            }
        }
        
        return result.sorted { $0.0 < $1.0 }
    }
    
    private func loadData() {
        let stats = realmManager.getStatsResults()
        
        listData = calculateTotalCounts(stats: stats)
    }
    
    private func calculateTotalCounts(stats: Results<Stats>) -> [ListElement] {
        let latestStatsByDate = statsFormatter.filterLatestStatsOnDayOfAllArticles(stats: Array(stats))
        
        // 各日付の最新データで集計
        var result: [ListElement] = []
        
        for dayStats in latestStatsByDate {
            let totalReadCount = dayStats.reduce(0) { $0 + $1.readCount }
            let totalLikeCount = dayStats.reduce(0) { $0 + $1.likeCount }
            let totalCommentCount = dayStats.reduce(0) { $0 + $1.commentCount }
            let articleCount = dayStats.count
            
            // 時間情報を保持したまま結果に追加
            if let latestTime = dayStats.first?.updatedAt {
                result.append(ListElement(date: latestTime, totalReadCount: totalReadCount, totalLikeCount: totalLikeCount, totalCommentCount: totalCommentCount, articleCount: articleCount))
            }
        }
        
        result.sort { $0.date > $1.date }
        
        return result
    }
    
    private func handleGetStatsError(_ error: Error) {
        print(error)
        let title: String
        let detail: String
        
        switch error {
        case NAError.network(_), NAError.decoding(_):
            let naError = error as! NAError
            title = "取得エラー"
            detail = naError.userMessage
            
        case NAError.auth(_):
            let naError = error as! NAError
            title = "認証エラー"
            detail = naError.userMessage
            
        default:
            title = "不明なエラー"
            detail = "統計情報の取得中に不明なエラーが発生しました。\n\(error.localizedDescription)"
        }
        
        alertEntity = .init(singleButtonAlert: title, message: detail)
        
//        alertEntity = AlertEntity(title: title, message: detail, button: .single())
//        isShowAlert = true
    }
}

struct ListElement {
    let id = UUID()
    let date: Date
    let totalReadCount: Int
    let totalLikeCount: Int
    let totalCommentCount: Int
    let articleCount: Int
}
