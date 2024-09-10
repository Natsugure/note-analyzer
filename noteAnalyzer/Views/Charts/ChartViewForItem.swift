//
//  ChartViewForItem.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/28.
//

import SwiftUI
import Charts
import RealmSwift

struct ChartViewForItem: View {
    let item: Item
    let statsType: StatsType
    
    var chartData: [(Date, Int)] {
        let calendar = Calendar.current
        
        switch statsType {
        case .view:
            return item.stats.map { (calendar.startOfDay(for: $0.updatedAt), $0.readCount) }
                .sorted { $0.0 < $1.0 }
            
        case .comment:
            return item.stats.map { (calendar.startOfDay(for: $0.updatedAt), $0.commentCount) }
                .sorted { $0.0 < $1.0 }
            
        case .like:
            return item.stats.map { (calendar.startOfDay(for: $0.updatedAt), $0.likeCount) }
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
        ScrollView(.horizontal) {
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
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(dateFormatter.string(from: date))
                                .rotationEffect(.degrees(-90)) // テキストを90度回転
                                .fixedSize() // テキストの省略を防ぐ
                                .frame(width: 30) // 必要に応じて幅を調整
                                .padding(.bottom, 10) // 下部に余白を追加
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
            .frame(width: calculatedChartWidth)
            .padding(.trailing, 10)
            .padding(.top, 10)
        }
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
    
    ///データ点の数に基づいて計算されたChartViewの幅
    var calculatedChartWidth: CGFloat {
        let calendar = Calendar.current
        let daysBetween = calendar.dateComponents([.day], from: chartXDomain.lowerBound, to: chartXDomain.upperBound).day ?? 0
        let widthPerDay: CGFloat = 20
        return max(500, CGFloat(daysBetween + 1) * widthPerDay) // +1 は終了日を含むため
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
}
