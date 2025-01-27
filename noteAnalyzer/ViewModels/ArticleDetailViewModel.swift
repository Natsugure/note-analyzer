//
//  ArticleDetailViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/27.
//

import Foundation

@MainActor
final class ArticleDetailViewModel: ObservableObject {
    @Published var item: Item
    @Published var listData: [Stats] = []
    @Published var chartData: [(Date, Int)] = []
    @Published var selectionChartType: StatsType
    
    var statsFormatter = StatsFormatter()
    let calendar = Calendar(identifier: .gregorian)
    
    init(item: Item, selectionChartType: StatsType) {
        self.item = item
        self.selectionChartType = selectionChartType
        
        loadStatsData()
    }
    
    private func loadStatsData() {
        listData = statsFormatter.filterLatestStatsOnDay(stats: item.stats).sorted { $0.updatedAt > $1.updatedAt }
        
        calculateChartData()
    }
    
    func calculateChartData() {
        let result: [(Date, Int)]
        switch selectionChartType {
        case .view:
            result = listData.map { (calendar.startOfDay(for: $0.updatedAt), $0.readCount) }
        case .comment:
            result = listData.map { (calendar.startOfDay(for: $0.updatedAt), $0.commentCount) }
        case .like:
            result = listData.map { (calendar.startOfDay(for: $0.updatedAt), $0.likeCount) }
        }
        
        chartData = result.sorted { $0.0 < $1.0 }
    }
}
