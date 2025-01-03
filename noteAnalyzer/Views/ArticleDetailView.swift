//
//  ArticleDetailView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/28.
//

import SwiftUI
import RealmSwift

struct ArticleDetailView: View {
    var item: Item
    @Binding var path: [Item]
    @Binding var selection: StatsType
    
    var body: some View {
        VStack {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)
                .padding()
            
            Picker(selection: $selection, label: Text("グラフ選択")) {
                Text("ビュー").tag(StatsType.view)
                Text("コメント").tag(StatsType.comment)
                Text("スキ").tag(StatsType.like)
            }
            .pickerStyle(.segmented)
            
            ChartViewForItem(item: item, statsType: selection)
                .frame(height: 300)
                .padding()
            
            List {
                Section(header:
                            HStack {
                    Text("取得日時").bold()
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 10)
                    Text("ビュー").bold()
                        .frame(width: 60)
                    Text("コメント").bold()
                        .frame(width: 40)
                    Text("スキ").bold()
                        .frame(width: 40)
                        .padding(.trailing, 10)
                }
                    .font(.system(size: 12))
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .listRowInsets(EdgeInsets())
                ) {
                    //TODO: 1日の中で最新のデータのみ参照するように変更
                    ForEach(calculateTotalCounts(), id: \.0) { (updatedAt, readCount, likeCount, commentCount) in
                        HStack {
                            Text(formatDate(updatedAt))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            ZStack {
                                AppConstants.BrandColor.read.opacity(0.5)
                                Text(String(readCount))
                            }
                            .frame(width: 60)
                            ZStack {
                                AppConstants.BrandColor.comment.opacity(0.5)
                                Text(String(commentCount))
                            }
                            .frame(width: 40)
                            ZStack {
                                AppConstants.BrandColor.likeBackground
                                Text(String(likeCount))
                            }
                            .frame(width: 40)
                        .padding(.trailing, 10)
                        }
                        .font(.system(size: 12))
                    .listRowInsets(EdgeInsets())
                    }

                }
            }
            .listStyle(PlainListStyle())

            .navigationTitle("記事詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func calculateTotalCounts() -> [(Date, Int, Int, Int)] {
        // 日付のみを取得する関数
        func dateOnly(from date: Date) -> Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: components) ?? date
        }
        
        // 日付でグループ化し、各日付の最新データを保持
        var latestStatsByDate: [Date: [Stats]] = [:]
        
        for stat in item.stats {
            let dateKey = dateOnly(from: stat.updatedAt)
            
            if latestStatsByDate[dateKey] == nil {
                latestStatsByDate[dateKey] = [stat]
            } else {
                // 同じ日付の場合、時間を比較
                if let existingStats = latestStatsByDate[dateKey],
                   let existingTime = existingStats.first?.updatedAt,
                   stat.updatedAt > existingTime {
                    // より新しい時間のデータに更新
                    latestStatsByDate[dateKey] = [stat]
                } else if let existingStats = latestStatsByDate[dateKey],
                          let existingTime = existingStats.first?.updatedAt,
                          stat.updatedAt == existingTime {
                    // 同じ時間のデータは追加
                    latestStatsByDate[dateKey]?.append(stat)
                }
            }
        }
        
        // 各日付の最新データで集計
        var result: [(Date, Int, Int, Int)] = []
        
        for (_, dayStats) in latestStatsByDate {
            let totalReadCount = dayStats.reduce(0) { $0 + $1.readCount }
            let totalLikeCount = dayStats.reduce(0) { $0 + $1.likeCount }
            let totalCommentCount = dayStats.reduce(0) { $0 + $1.commentCount }
            
            // 時間情報を保持したまま結果に追加
            if let latestTime = dayStats.first?.updatedAt {
                result.append((latestTime, totalReadCount, totalLikeCount, totalCommentCount))
            }
        }
        
        // 更新日でソート（降順）
        result.sort { $0.0 > $1.0 }
        
        return result
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    @State static var samplePath = [Item(value: [
        "id": 1,
        "title": "サンプル記事タイトル",
        "type": ContentType.text.rawValue,
        "publishedAt": Date() - 750000,
        "stats": [
            Stats(value: [
                "id": UUID().uuidString,
                "updatedAt": Date(),
                "readCount": 100,
                "likeCount": 50,
                "commentCount": 10
            ])
        ]
    ])]
    
    static var previews: some View {
        ArticleDetailView(item: samplePath[0], path: $samplePath, selection: .constant(.view))
    }
}
