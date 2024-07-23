//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/23.
//

import SwiftUI
import RealmSwift
import Charts

struct DashboardView: View {
    @ObservedObject var networkManager = NetworkManager()
    @ObservedResults(Item.self) var items
    
    var body: some View {
        NavigationStack {
            VStack {
                ChartView(items: items)
                    .frame(height: 300)
                    .padding(.horizontal, 20)
                
                List {
                    Section(header:
                                HStack {
                        Text("記事").bold()
                            .frame(maxWidth: .infinity)
                            .padding(.leading, 10)
                        Text("ビュー").bold()
                            .frame(width: 40)
                        Text("スキ").bold()
                            .frame(width: 40)
                        Text("コメント").bold()
                            .frame(width: 40)
                            .padding(.trailing, 10)
                    }
                        .font(.system(size: 12))
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .listRowInsets(EdgeInsets())
                    ) {
                        
                        // データ行
                        ForEach(items) { item in
                            HStack(alignment: .center) {
                                Text(item.title)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                                Text(String(item.stats.last?.readCount ?? 0))
                                    .frame(width: 40)
                                Text(String(item.stats.last?.likeCount ?? 0))
                                    .frame(width: 40)
                                Text(String(item.stats.last?.commentCount ?? 0))
                                    .frame(width: 40)
                                    .padding(.trailing, 10)
                            }
                            .font(.system(size: 12))
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .listStyle(PlainListStyle())

                .toolbar {
                    //フィルターボタン
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    //更新ボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                await networkManager.getStats()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
        }
    }
}

struct ChartView: View {
    let items: Results<Item>
    
    var chartData: [(Date, Int)] {
        let allStats = items.flatMap { $0.stats }
        let groupedStats = Dictionary(grouping: allStats) { stat in
            Calendar.current.startOfDay(for: stat.updatedAt)
        }
        
        return groupedStats.map { (date, stats) in
            let totalReadCount = stats.reduce(0) { $0 + $1.readCount }
            return (date, totalReadCount)
        }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        Chart {
                ForEach(chartData, id: \.0) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.0),
                        y: .value("Total Read Count", dataPoint.1)
                    )
                    PointMark(
                        x: .value("Date", dataPoint.0),
                        y: .value("Total Read Count", dataPoint.1)
                    )
                }
            }
            .chartXScale(domain: chartXDomain)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        let isInDataRange = chartData.contains { Calendar.current.isDate($0.0, inSameDayAs: date) }
                        if isInDataRange {
                            AxisValueLabel(format: .dateTime.month().day())
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

#Preview {
    DashboardView()
}
