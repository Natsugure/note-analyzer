//
//  StatsFormatter.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/05.
//

import Foundation
import RealmSwift

struct StatsFormatter {
    let calendar = Calendar(identifier: .gregorian)
    
    func filterLatestStatsOnDayOfAllArticles(stats: [Stats]) -> [[Stats]] {
        var filteredStats: [Date: [Stats]] = [:]
        
        for stat in stats {
            let dateKey = calendar.startOfDay(for: stat.updatedAt)
            
            if filteredStats[dateKey] == nil {
                filteredStats[dateKey] = [stat]
            } else {
                // 同じ日付の場合、時間を比較
                if let existingStats = filteredStats[dateKey],
                   let existingTime = existingStats.first?.updatedAt,
                   stat.updatedAt > existingTime {
                    // より新しい時間のデータに更新
                    filteredStats[dateKey] = [stat]
                } else if let existingStats = filteredStats[dateKey],
                          let existingTime = existingStats.first?.updatedAt,
                          stat.updatedAt == existingTime {
                    // 同じ時間のデータは追加
                    filteredStats[dateKey]?.append(stat)
                }
            }
        }
        
        return Array(filteredStats.values)
    }
    
    func filterLatestStatsOnDay(stats: RealmSwift.List<Stats>) -> [Stats] {
        Dictionary(grouping: stats) { calendar.startOfDay(for: $0.updatedAt) }
        .mapValues { $0.max(by: { $0.updatedAt < $1.updatedAt}) }
        .compactMap { $0.value }
    }
}
