//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/23.
//

import SwiftUI
import RealmSwift

//enum StatsType {
//    case view
//    case comment
//    case like
//}

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @StateObject var alertObject = AlertObject()
    @State private var path = [Item]()
    
//    var statsFormatter = StatsFormatter()

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                VStack {
                    Picker(selection: $viewModel.selectionChartType, label: Text("グラフ選択")) {
                        Text("ビュー").tag(StatsType.view)
                        Text("コメント").tag(StatsType.comment)
                        Text("スキ").tag(StatsType.like)
                    }
                    .pickerStyle(.segmented)
                    
                    ChartView(chartData: viewModel.calculateChartData(), statsType: viewModel.selectionChartType)
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
            .customAlert(for: alertObject, isPresented: $viewModel.isShowAlert)
        }
    }
    
    ///取得日ごとの統計情報を表示する`List`
    private var statsList: some View {
        List {
            Section(
                header:
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
                ForEach(viewModel.listData, id: \.id) { element in
                    NavigationLink(destination: DailyView(path: $path, selectionChartType: $viewModel.selectionChartType, selectedDate: element.date)) {
                        DashboardListRow(element: element)
                    }
                }
                .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10)))
            }
        }
        .listStyle(PlainListStyle())
    }
    
    //MARK: - The methods of connect to ViewModel
    private func getStats() async {
        do {
            try await viewModel.getStats()
            
            alertObject.showSingle(
                isPresented: $viewModel.isShowAlert,
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
        
        alertObject.showSingle(isPresented: $viewModel.isShowAlert, title: title, message: detail)
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


