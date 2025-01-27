//
//  DailyView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/04.
//

import SwiftUI

struct DailyView: View {
    @StateObject var viewModel: DailyViewModel
    @Binding var selectionChartType: StatsType
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    HStack {
                        Text("ビュー")
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        Text(formattedString(from: viewModel.totalCount(for: \.readCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(viewModel.differenceString(for: \.readCount))
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 6)
                    .background(AppConstants.BrandColor.read.opacity(0.5))
                    
                    HStack {
                        Text("コメント")
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        Text(formattedString(from: viewModel.totalCount(for: \.commentCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(viewModel.differenceString(for: \.commentCount))
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 6)
                    .background(AppConstants.BrandColor.comment.opacity(0.3))
                    
                    HStack {
                        Text("スキ")
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        Text(formattedString(from: viewModel.totalCount(for: \.likeCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(viewModel.differenceString(for: \.likeCount))
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 6)
                    .background(AppConstants.BrandColor.likeBackground)
                }
                .padding()
                
                VStack {
                    HStack {
                        Button(action: {
                            viewModel.isShowFilterSheet.toggle()
                        }, label: {
                            Text(Image(systemName: "line.3.horizontal.decrease.circle")) + Text("絞り込み")
                            
                        })
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 1, x: 1, y: 1)
                        .padding(.horizontal)
                        
                        Menu {
                            Picker("並び替え", selection: $viewModel.sortType) {
                                ForEach(SortType.allCases, id: \.self) { type in
                                    Text("\(type.rawValue)")
                                        .tag(type)
                                }
                            }
                        } label: {
                            Text(Image(systemName: "arrow.up.arrow.down.circle")) + Text("並び替え")
                        }
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(Color.cyan)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 1, x: 1, y: 1)
                        .padding(.horizontal)
                    }
                    
                    List {
                        Section(header:
                                    HStack {
                            Text("記事情報").bold()
                                .frame(maxWidth: .infinity)
                                .padding(.leading, 10)
                            Text("ビュー").bold()
                                .frame(width: 80)
                            Text("コメント").bold()
                                .frame(width: 50)
                            Text("スキ").bold()
                                .frame(width: 60)
                                .padding(.trailing, 27)
                        }
                            .font(.system(size: 12))
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .listRowInsets(EdgeInsets())
                        ) {
                            // データ行
                            ForEach(viewModel.listItems) { item in
                                NavigationLink(
                                    destination: ArticleDetailView(
                                        viewModel: ArticleDetailViewModel(item: item, selectionChartType: selectionChartType)
                                    )
                                ) {
                                    HStack(alignment: .center) {
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 10)
                                        
                                        VStack(alignment: .leading) {
                                            HStack() {
                                                Text(item.publishedAt.formatted(Date.FormatStyle(date: .numeric, time: .omitted)))
                                                    .font(.system(size: 12))
                                            }
                                            Text(item.title)
                                                .lineLimit(2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 0.1)
                                        }
                                        .padding(.vertical, 3)
                                        
                                        ZStack {
                                            AppConstants.BrandColor.read.opacity(0.5)
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: viewModel.selectedDate) }?.readCount ?? 0))
                                        }
                                        .frame(width: 80)
                                        ZStack {
                                            AppConstants.BrandColor.comment.opacity(0.3)
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: viewModel.selectedDate) }?.commentCount ?? 0))
                                        }
                                        .frame(width: 50)
                                        ZStack {
                                            AppConstants.BrandColor.likeBackground
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: viewModel.selectedDate) }?.likeCount ?? 0))
                                        }
                                        .frame(width: 60)
                                    }
                                    .font(.system(size: 16))
                                }
                            }
                            .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10)))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
            }
            .navigationTitle("\(viewModel.selectedDate, formatter: dateFormatter) 統計")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isShowFilterSheet) {
                FilterSelecterView(isShowFilterSheet: $viewModel.isShowFilterSheet, isEnablePublishDateFliter: $viewModel.isEnablePublishDateFliter, startDate: $viewModel.startDate, endDate: $viewModel.endDate, selectionContentTypes: $viewModel.selectionContentTypes)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/"
        return formatter
    }()
    
    private let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
    
    private func formattedString<T: Numeric>(from number: T) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let intNumber = number as? Int {
            return formatter.string(from: NSNumber(value: intNumber)) ?? "0"
        } else if let doubleNumber = number as? Double {
            return formatter.string(from: NSNumber(value: doubleNumber)) ?? "0"
        } else if let floatNumber = number as? Float {
            return formatter.string(from: NSNumber(value: floatNumber)) ?? "0"
        } else {
            return "0"
        }
    }
}

struct FilterSelecterView: View {
    @Binding var isShowFilterSheet: Bool
    @Binding var isEnablePublishDateFliter: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectionContentTypes: Set<ContentType>
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Text("絞り込み条件設定")
                        .font(.system(.title3, weight: .bold))
                        .frame(width: geometry.size.width, alignment: .center)
                    
                    Button("完了") {
                        isShowFilterSheet.toggle()
                    }
                    .padding(.trailing)
                    .frame(width: geometry.size.width, alignment: .trailing)
                }
                .frame(height: geometry.size.height)
                .padding(.vertical, 8)
            }
            .frame(height: 44)
            
            List(selection: $selectionContentTypes) {
                Section("投稿日") {
                    Toggle(isOn: $isEnablePublishDateFliter) {
                        Text("投稿日による絞り込みを有効化")
                    }
                    
                    VStack {
                        DatePicker("開始日", selection: $startDate, displayedComponents: [.date])
                        DatePicker("終了日", selection: $endDate, displayedComponents: [.date])
                    }
                    .opacity(isEnablePublishDateFliter ? 1 : 0.3)
                    .animation(.default, value: isEnablePublishDateFliter)

                }
                
                Section("投稿の種類") {
                    ForEach(ContentType.allCases, id: \.self) {
                        Text($0.name)
                    }
                    .listRowBackground(Color.white)
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
}

struct SortSelecterView: View {
    @Binding var isShowSortView: Bool
    @Binding var sortType: SortType
    
    var body: some View {
        VStack {
            
        }
    }
}

//struct DailyView_Previews: PreviewProvider {
//    @State static var mockPath: [Item] = []
//    @State static var mockSelection: StatsType = .view
//    
//    static var previews: some View {
////        let item = PreviewData.realm.objects(Item.self)
//        
//        @ObservedResults(Item.self, configuration: PreviewData.realm.configuration) var items
//        print(items)
//        let calendar = Calendar.current
//        return DailyView(
//            items: $items,
//            path: $mockPath,
//            selectionChartType: $mockSelection,
//            selectedDate: calendar.date(from: DateComponents(year: 2024, month: 7, day: 7))!
//        )
//        .environment(\.realmConfiguration, PreviewData.realm.configuration)
//    }
//
////    static var previews: some View {
////        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "PreviewRealm"))
////        
////        let mockUpdateAt = Date()
////        
////        let mockItem = Item()
////        mockItem.id = 999
////        mockItem.title = "Sample Item"
////        mockItem.publishedAt = mockUpdateAt - 87740
////        
////        let mockStats = Stats()
////        mockStats.updatedAt = mockUpdateAt
////        mockStats.readCount = 100
////        mockStats.likeCount = 50
////        mockStats.commentCount = 10
////        
////        if realm.object(ofType: Item.self, forPrimaryKey: mockItem.id) == nil {
////            try! realm.write {
////                mockItem.stats.append(mockStats)
////                realm.add(mockItem)
////            }
////        }
////        
////        return DailyView(path: $mockPath, selectionChartType: $mockSelection, selectedDate: mockUpdateAt)
////            .environment(\.realmConfiguration, realm.configuration)
////            .environment(\.locale, Locale(identifier: "ja_JP"))
////    }
//}
