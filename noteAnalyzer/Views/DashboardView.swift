//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/23.
//

import SwiftUI
import RealmSwift

enum StatsType {
    case view
    case comment
    case like
}

struct DashboardView: View {
    @ObservedObject var networkManager = NetworkManager()
    @ObservedResults(Item.self) var items
    @State private var path = [Item]()
    @State private var selection: StatsType = .view
    
    var sortedItems: [Item] {
        items.sorted { (item1, item2) -> Bool in
            let readCount1 = item1.stats.last?.readCount ?? 0
            let readCount2 = item2.stats.last?.readCount ?? 0
            return readCount1 > readCount2
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Picker(selection: $selection, label: Text("グラフ選択")) {
                    Text("ビュー").tag(StatsType.view)
                    Text("コメント").tag(StatsType.comment)
                    Text("スキ").tag(StatsType.like)
                }
                .pickerStyle(.segmented)
                
                ChartViewForAll(items: items, statsType: selection)
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
                        // データ行
                        ForEach(sortedItems) { item in
                            NavigationLink(destination: ArticleDetailView(item: item, path: $path, selection: $selection)) {
                                HStack(alignment: .center) {
                                    Text(item.title)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 10)
                                    Text(String(item.stats.last?.readCount ?? 0))
                                        .frame(width: 40)
                                    Text(String(item.stats.last?.commentCount ?? 0))
                                        .frame(width: 40)
                                    Text(String(item.stats.last?.likeCount ?? 0))
                                        .frame(width: 40)
                                        .padding(.trailing, 10)
                                }
                                .font(.system(size: 12))
                            .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                .navigationTitle("全記事統計")
                .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    DashboardView()
}
