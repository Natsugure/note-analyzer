//
//  DashboardView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/23.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Picker(selection: $viewModel.selectionChartType, label: Text("グラフ選択")) {
                        Text("ビュー").tag(StatsType.view)
                        Text("コメント").tag(StatsType.comment)
                        Text("スキ").tag(StatsType.like)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
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
                .transaction(value: viewModel.isPresentedProgressView) { transaction in
                    transaction.disablesAnimations = true
                }
                .navigationTitle("全記事統計")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //更新ボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { Task { await viewModel.getStats() } }, label: { Image(systemName: "arrow.counterclockwise") })
                    }
                }
            }
            .customAlert(entity: $viewModel.alertEntity)
        }
    }
    
    ///取得日ごとの統計情報を表示する`List`
    @MainActor
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
                    NavigationLink(
                        destination: DailyView(
                            viewModel: DailyViewModel(date: element.date, realmManager: RealmManager()),
                            selectionChartType: $viewModel.selectionChartType)
                    ) {
                        DashboardListRow(element: element)
                    }
                }
                .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10)))
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct DashboardView_Previews: PreviewProvider {
    static let authManager = MockAuthenticationService()
    static let networkService = MockNetworkService(provider: MockDataProvider())
    static let realmManager = RealmManager()
    static let apiClient = NoteAPIClient(authManager: authManager, networkService: networkService)
    
    static var previews: some View {
        DashboardView(viewModel: DashboardViewModel(apiClient: apiClient, realmManager: realmManager))
    }
}


