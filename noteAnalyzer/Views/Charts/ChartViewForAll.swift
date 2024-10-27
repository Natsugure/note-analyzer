//
//  ChartViewForAll.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/28.
//

import SwiftUI
import Charts
import RealmSwift

struct ChartViewForAll: View {
    let items: Results<Item>
    let statsType: StatsType
    
    var chartData: [(Date, Int)] {
        // 日付のみを取得する関数
        func dateOnly(from date: Date) -> Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: components) ?? date
        }
        
        // まず日付ごとに最新の統計データをグループ化
        var latestStatsByDate: [Date: [Stats]] = [:]
        
        for item in items {
            for stat in item.stats {
                let dateKey = dateOnly(from: stat.updatedAt)
                
                if latestStatsByDate[dateKey] == nil {
                    latestStatsByDate[dateKey] = [stat]
                } else {
                    // 同じ日付の場合、時間を比較
                    if let existingStats = latestStatsByDate[dateKey],
                       let existingTime = existingStats.first?.updatedAt,
                       stat.updatedAt > existingTime {
                        // より新しい時間のデータで更新
                        latestStatsByDate[dateKey] = [stat]
                    } else if let existingStats = latestStatsByDate[dateKey],
                              let existingTime = existingStats.first?.updatedAt,
                              stat.updatedAt == existingTime {
                        // 同じ時間のデータは追加
                        latestStatsByDate[dateKey]?.append(stat)
                    }
                }
            }
        }
        
        // 各日付の最新データで集計
        var result: [(Date, Int)] = []
        
        for (date, dayStats) in latestStatsByDate {
            let totalValue = dayStats.reduce(0) { total, stat in
                switch statsType {
                case .view:
                    return total + stat.readCount
                case .comment:
                    return total + stat.commentCount
                case .like:
                    return total + stat.likeCount
                }
            }
            
            // 時間情報を保持したまま結果に追加
            if let latestTime = dayStats.first?.updatedAt {
                result.append((latestTime, totalValue))
            }
        }
        
        // 日付でソート（昇順）
        return result.sorted { $0.0 < $1.0 }
        
//        var dataDict: [Date: Int] = [:]
//        let calendar = Calendar.current
//
//        for item in items {
//            for stat in item.stats {
//                let date = calendar.startOfDay(for: stat.updatedAt) // 日付のみを使用
//                let value: Int
//                switch statsType {
//                case .view:
//                    value = stat.readCount
//                case .comment:
//                    value = stat.commentCount
//                case .like:
//                    value = stat.likeCount
//                }
//                dataDict[date, default: 0] += value
//            }
//        }
//
//        return dataDict.sorted { $0.key < $1.key }
    }
    
    var lineColor: Color {
        switch statsType {
        case .view:
            return AppConstants.BrandColor.read
        case .comment:
            return AppConstants.BrandColor.comment
        case .like:
            return AppConstants.BrandColor.like
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
                                .rotationEffect(.degrees(-90))
                                .fixedSize()
                                .frame(width: 30)
                                .padding(.bottom, 10)
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
