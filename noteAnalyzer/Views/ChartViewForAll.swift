//
//  ChartViewForAll.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/28.
//

import SwiftUI
import Charts
import RealmSwift

struct ChartViewForAll: View {
    let items: Results<Item>
    let statsType: StatsType
    
    var chartData: [(Date, Int)] {
        let allStats = items.flatMap { $0.stats }
        let groupedStats = Dictionary(grouping: allStats) { stat in
            Calendar.current.startOfDay(for: stat.updatedAt)
        }
        
        return groupedStats.map { (date, stats) in
            switch statsType {
            case .view:
                let totalReadCount = stats.reduce(0) { $0 + $1.readCount }
                return (date, totalReadCount)
            case .comment:
                let totalCommentCount = stats.reduce(0) { $0 + $1.commentCount }
                return (date, totalCommentCount)
            case .like:
                let totalLikeCount = stats.reduce(0) { $0 + $1.likeCount }
                return (date, totalLikeCount)
            }
        }.sorted { $0.0 < $1.0 }
    }
    
    var lineColor: Color {
        switch statsType {
        case .view:
            return K.BrandColor.read
        case .comment:
            return K.BrandColor.comment
        case .like:
            return K.BrandColor.like
        }
    }
    
    var body: some View {
        Chart {
                ForEach(chartData, id: \.0) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.0),
                        y: .value("Total Count", dataPoint.1)
                    )
                    .foregroundStyle(lineColor)
                    
                    PointMark(
                        x: .value("Date", dataPoint.0),
                        y: .value("Total Count", dataPoint.1)
                    )
                    .foregroundStyle(lineColor)
                }
            }
            .chartXScale(domain: chartXDomain)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        let isInDataRange = chartData.contains { Calendar.current.isDate($0.0, inSameDayAs: date) }
                        if isInDataRange {
                            AxisValueLabel(format: .dateTime.month(.twoDigits).day(.twoDigits))
                        }
                        AxisTick()
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: chartYDomain)
    }
    
    var chartXDomain: ClosedRange<Date> {
        guard let minDate = chartData.first?.0, let maxDate = chartData.last?.0 else {
            return Date()...Date()
        }
        return minDate...maxDate
    }
    
    var chartYDomain: ClosedRange<Int> {
        let counts = chartData.map { $0.1 }
        guard let minCount = counts.min(), let maxCount = counts.max() else {
            return 0...100
        }
        let padding = max(1, (maxCount - minCount) / 10)
        return (minCount - padding)...(maxCount + padding)
    }
}

//#Preview {
//    ChartView()
//}
