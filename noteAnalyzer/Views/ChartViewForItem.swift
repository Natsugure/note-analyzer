//
//  ChartViewForItem.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/28.
//

import SwiftUI
import Charts
import RealmSwift

struct ChartViewForItem: View {
    let item: Item
    let statsType: StatsType
    
    var chartData: [(Date, Int)] {
        switch statsType {
        case .view:
            return item.stats.map { ($0.updatedAt, $0.readCount) }
                .sorted { $0.0 < $1.0 }
            
        case .comment:
            return item.stats.map { ($0.updatedAt, $0.commentCount) }
                .sorted { $0.0 < $1.0 }
            
        case .like:
            return item.stats.map { ($0.updatedAt, $0.likeCount) }
                .sorted { $0.0 < $1.0 }
        }
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
                    y: .value("Count", dataPoint.1)
                )
                .foregroundStyle(lineColor)
                
                PointMark(
                    x: .value("Date", dataPoint.0),
                    y: .value("Count", dataPoint.1)
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
