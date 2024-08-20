//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/23.
//

import SwiftUI
import RealmSwift

enum StatsType {
    case view
    case comment
    case like
}

struct DashboardView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    @ObservedObject var alertObject = AlertObject()
    @ObservedResults(Item.self) var items
    @ObservedResults(Stats.self) var stats
    @State private var path = [Item]()
    @State private var selection: StatsType = .view
    @State private var sortType: SortType = .view

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
                    .padding(.vertical, 10)
                
                List {
                    Section(header:
                                HStack {
                        Text("更新日").bold()
                            .frame(maxWidth: .infinity)
                        Text("記事数").bold()
                            .frame(maxWidth: 40)
                        Text("ビュー").bold()
                            .frame(width: 80)
                        Text("コメント").bold()
                            .frame(width: 60)
                        Text("スキ").bold()
                            .frame(width: 60)
                            .padding(.trailing, 27)

                    }
                        .font(.system(size: 12))
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .listRowInsets(EdgeInsets())
                    ) {
                        ForEach(calculateTotalCounts(), id: \.0) { (date, readCount, likeCount, commentCount, articleCount) in
                            NavigationLink(destination: DailyView(path: $path, selection: $selection, selectedDate: date)) {
                                HStack {
                                    VStack {
                                        Text("\(date, formatter: dateFormatter)")
                                        Text(dateToTimeString(date: date))
                                    }
                                    .frame(maxWidth: .infinity)
                                    Text("\(articleCount)")
                                        .frame(width: 40)
                                    ZStack {
                                        K.BrandColor.read.opacity(0.5)
                                        Text("\(readCount)")
                                    }
                                    .frame(width: 80)
                                    ZStack {
                                        K.BrandColor.comment.opacity(0.3)
                                        Text("\(commentCount)")
                                    }
                                    .frame(width: 60)
                                    ZStack {
                                        K.BrandColor.likeBackground
                                        Text("\(likeCount)")
                                    }
                                    .frame(width: 60)
                                }
                                .font(.system(size: 12))
                            }
                        }
                        .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10)))
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
                                do {
                                    try await viewModel.getStats()
                                    alertObject.showAlert(title: "取得完了", message: "統計情報の取得が完了しました。")
                                } catch NoteViewModelError.statsNotUpdated {
                                    alertObject.showAlert(title: "取得エラー", message: "前回の取得以降、まだ統計が更新されていません。\n 時間が経ってから再度お試しください。")
                                } catch {
                                    alertObject.showAlert(title: "取得エラー", message: "ネットワーク上でエラーが発生しました。\n \(error)")
                                }
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .customAlert(for: alertObject)
                    }
                }
            }
        }
    }
    
    private func calculateTotalCounts() -> [(Date, Int, Int, Int, Int)] {
        var countsByDate: [Date: (readCount: Int, likeCount: Int, commentCount: Int, articleCount: Int)] = [:]
        
        for stat in stats {
            let date = stat.updatedAt
            
            if countsByDate[date] == nil {
                countsByDate[date] = (readCount: 0, likeCount: 0, commentCount: 0, articleCount: 0)
            }
            
            countsByDate[date]?.readCount += stat.readCount
            countsByDate[date]?.likeCount += stat.likeCount
            countsByDate[date]?.commentCount += stat.commentCount
            countsByDate[date]?.articleCount += 1 //記事の数をカウント
        }
        
        // 結果を配列に変換
        var result = countsByDate.map { (date, counts) in
            return (date, counts.readCount, counts.likeCount, counts.commentCount, counts.articleCount)
        }
        
        // 更新日でソート
        result.sort { $0.0 > $1.0 }
        
        return result
    }
    
    private func dateToTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    // 日付フォーマッター
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}
    

struct DashboardView_Previews: PreviewProvider {
    static let authManager = AuthenticationManager()
    static let networkService = NetworkService(authManager: authManager)
    static let realmManager = RealmManager()
    
    static var previews: some View {
        DashboardView()
            .environmentObject(NoteViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
    }
}
