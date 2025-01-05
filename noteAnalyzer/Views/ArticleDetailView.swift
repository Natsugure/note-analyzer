//
//  ArticleDetailView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/28.
//

import SwiftUI
import RealmSwift

struct ArticleDetailView: View {
    @ObservedRealmObject var item: Item
    @Binding var path: [Item]
    @Binding var selection: StatsType
    
    var statsFormatter = StatsFormatter()
    
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
        let latestStatsByDate = statsFormatter.filterLatestStatsOnDay(stats: Array(item.stats))
        
        var result = latestStatsByDate.map { ($0.updatedAt, $0.readCount, $0.likeCount, $0.commentCount) }
        
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
