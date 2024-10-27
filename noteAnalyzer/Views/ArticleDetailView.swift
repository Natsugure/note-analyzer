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
                    ForEach(item.stats.sorted(by: { $0.updatedAt > $1.updatedAt })) { stats in
                        HStack {
                            Text(formatDate(stats.updatedAt))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            ZStack {
                                AppConstants.BrandColor.read.opacity(0.5)
                                Text(String(stats.readCount))
                            }
                            .frame(width: 60)
                            ZStack {
                                AppConstants.BrandColor.comment.opacity(0.5)
                                Text(String(stats.commentCount))
                            }
                            .frame(width: 40)
                            ZStack {
                                AppConstants.BrandColor.likeBackground
                                Text(String(stats.likeCount))
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
