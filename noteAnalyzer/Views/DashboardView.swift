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
    @StateObject var viewModel: DashboardViewModel
    @StateObject var alertObject = AlertObject()
    // TODO: ここでObservedResutlsを使ってるせいで、RealmのマイグレーションブロックをRealmManagerとAppDelegateの2箇所に置く羽目になっている。やはり責務をRealmManagerに統一すべき。
    @ObservedResults(Item.self) var items
    @ObservedResults(Stats.self) var stats
    @State private var path = [Item]()
    @State private var selectionChartType: StatsType = .view
    @State private var sortType: SortType = .viewDecending
    
    var statsFormatter = StatsFormatter()
    
    @State var isShowAlert = false

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                VStack {
                    Picker(selection: $selectionChartType, label: Text("グラフ選択")) {
                        Text("ビュー").tag(StatsType.view)
                        Text("コメント").tag(StatsType.comment)
                        Text("スキ").tag(StatsType.like)
                    }
                    .pickerStyle(.segmented)
                    
                    ChartView(chartData: calculateChartData(), statsType: selectionChartType)
                        .frame(height: geometry.size.height * 0.4)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    statsList
                }
                .fullScreenCover(isPresented: $viewModel.isPresentedProgressView) {
                    BackgroundClearProgressBarView(progressValue: $viewModel.progressValue)
                        .presentationBackground(Color.clear)
                }
                .navigationTitle("全記事統計")
                .navigationBarItems(leading: EmptyView())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //更新ボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { Task { await getStats() } }, label: { Image(systemName: "arrow.counterclockwise") })
                    }
                }
            }
//            .onAppear {
//                if items.isEmpty {
//                    alertObject.showDouble(
//                        isPresented: $isShowAlert,
//                        title: "",
//                        message: "アプリを利用するには、noteから統計情報を取得する必要があります。\n今すぐ取得しますか？",
//                        actionText: "取得する",
//                        action: {
//                            Task { await getStats() } }
//                    )
//                }
//            }
            .customAlert(for: alertObject, isPresented: $isShowAlert)
        }

    }
    
    ///取得日ごとの統計情報を表示する`List`
    private var statsList: some View {
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
                    NavigationLink(destination: DailyView(path: $path, selectionChartType: $selectionChartType, selectedDate: date)) {
                        HStack {
                            VStack {
                                Text("\(date, formatter: dateFormatter)")
                                Text(dateToTimeString(date: date))
                            }
                            .frame(maxWidth: .infinity)
                            Text("\(articleCount)")
                                .frame(width: 40)
                            ZStack {
                                AppConstants.BrandColor.read.opacity(0.5)
                                Text("\(readCount)")
                            }
                            .frame(width: 80)
                            ZStack {
                                AppConstants.BrandColor.comment.opacity(0.3)
                                Text("\(commentCount)")
                            }
                            .frame(width: 60)
                            ZStack {
                                AppConstants.BrandColor.likeBackground
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
    }
    
    //MARK: - Calculating and Formatting Stats Methods
    private func calculateTotalCounts() -> [(Date, Int, Int, Int, Int)] {
        let latestStatsByDate = statsFormatter.filterLatestStatsOnDayOfAllArticles(stats: Array(stats))
        
        // 各日付の最新データで集計
        var result: [(Date, Int, Int, Int, Int)] = []
        
        for dayStats in latestStatsByDate {
            let totalReadCount = dayStats.reduce(0) { $0 + $1.readCount }
            let totalLikeCount = dayStats.reduce(0) { $0 + $1.likeCount }
            let totalCommentCount = dayStats.reduce(0) { $0 + $1.commentCount }
            let articleCount = dayStats.count
            
            // 時間情報を保持したまま結果に追加
            if let latestTime = dayStats.first?.updatedAt {
                result.append((latestTime, totalReadCount, totalLikeCount, totalCommentCount, articleCount))
            }
        }
        
        // 更新日でソート（降順）
        result.sort { $0.0 > $1.0 }
        
        return result
    }
    
    private func calculateChartData() -> [(Date, Int)] {
        let latestStatsByDate = statsFormatter.filterLatestStatsOnDayOfAllArticles(stats: Array(stats))
        
        var result: [(Date, Int)] = []
        
        for dayStats in latestStatsByDate {
            let totalCount: Int
            switch selectionChartType {
            case .view:
                totalCount = dayStats.reduce(0) { $0 + $1.readCount }
            case .comment:
                totalCount = dayStats.reduce(0) { $0 + $1.commentCount }
            case .like:
                totalCount = dayStats.reduce(0) { $0 + $1.likeCount }
            }
            
            if let latestTime = dayStats.first?.updatedAt {
                result.append((DateUtils.calendar.startOfDay(for: latestTime), totalCount))
            }
        }
        
        return result.sorted { $0.0 < $1.0 }
    }
    
    private func dateToTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    //MARK: - The methods of connect to ViewModel
    private func getStats() async {
        do {
            try await viewModel.getStats()
            
            alertObject.showSingle(
                isPresented: $isShowAlert,
                title: "取得完了",
                message:  "統計情報の取得が完了しました。"
            )
        } catch {
            handleGetStatsError(error)
        }
    }
    
    private func handleGetStatsError(_ error: Error) {
        print(error)
        let title: String
        let detail: String
        
        switch error {
        case NAError.network(_), NAError.decoding(_):
            let naError = error as! NAError
            title = "取得エラー"
            detail = naError.userMessage
            
        case NAError.auth(_):
            let naError = error as! NAError
            title = "認証エラー"
            detail = naError.userMessage
            
        default:
            title = "不明なエラー"
            detail = "統計情報の取得中に不明なエラーが発生しました。\n\(error.localizedDescription)"
        }
        
        alertObject.showSingle(isPresented: $isShowAlert, title: title, message: detail)
    }
    

}

//struct DashboardView_Previews: PreviewProvider {
//    static let authManager = AuthenticationManager()
//    static let networkService = NetworkService(authManager: authManager)
//    static let realmManager = RealmManager()
//    @StateObject static var alertObject = AlertObject()
//    @State static var isPresentedProgressView = false
//    
//    static var previews: some View {
//        DashboardView(alertObject: alertObject, isPresentedProgressView: $isPresentedProgressView)
//            .environmentObject(ViewModel(authManager: authManager, networkService: networkService, realmManager: realmManager))
//    }
//}
