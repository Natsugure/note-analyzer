//
//  StatsFormatter.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/05.
//

import Foundation

struct StatsFormatter {
    func filterLatestStatsOnDayOfAllArticles(stats: [Stats]) -> [[Stats]] {
        var filteredStats: [Date: [Stats]] = [:]
        
        for stat in stats {
            let dateKey = dateOnly(from: stat.updatedAt)
            
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
    
    func filterLatestStatsOnDay(stats: [Stats]) -> [Stats] {
        var filteredStats: [Date: Stats] = [:]
        
        for stat in stats {
            let dateKey = dateOnly(from: stat.updatedAt)
            
            if filteredStats[dateKey] == nil {
                filteredStats[dateKey] = stat
            } else {
                if let existingStats = filteredStats[dateKey],
                   stat.updatedAt >= existingStats.updatedAt {
                    filteredStats[dateKey] = stat
                }
            }
        }
        
        return Array(filteredStats.values)
    }
    
    private func dateOnly(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}
