//
//  StatsFormatter.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/05.
//

import Foundation
import RealmSwift

struct StatsFormatter {
    let calendar = Calendar(identifier: .gregorian)
    
    func filterLatestStatsOnDayOfAllArticles(stats: Results<Stats>) -> [[Stats]] {
        Dictionary(grouping: stats) { calendar.startOfDay(for:  $0.updatedAt) }
            .mapValues { statsInDay -> [Stats] in
                let maxUpdatedAt = statsInDay.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt
                return statsInDay.filter { $0.updatedAt == maxUpdatedAt }
            }
            .compactMap { $0.value }
    }
    
    func filterLatestStatsOnDay(stats: RealmSwift.List<Stats>) -> [Stats] {
        Dictionary(grouping: stats) { calendar.startOfDay(for: $0.updatedAt) }
        .mapValues { $0.max(by: { $0.updatedAt < $1.updatedAt}) }
        .compactMap { $0.value }
    }
}
