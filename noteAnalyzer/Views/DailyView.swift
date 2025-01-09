//
//  DailyView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/04.
//

import SwiftUI
import RealmSwift

enum SortType: String, CaseIterable {
    case publishedAtNew = "投稿日時の新しい順"
    case publishedAtOld = "投稿日時の古い順"
    case viewDecending = "ビューの多い順"
    case viewAscending = "ビューの少ない順"
    case commentDecending = "コメントの多い順"
    case commentAscending = "コメントの少ない順"
    case likeDecending = "スキの多い順"
    case likeAscending = "スキの少ない順"
    
    var symbol: String {
        switch self {
        case .publishedAtNew:
            return "📅▼"
        case .publishedAtOld:
            return "📅▲"
        case .viewDecending:
            return "👀▼"
        case .viewAscending:
            return "👀▲"
        case .commentDecending:
            return "💬▼"
        case .commentAscending:
            return "💬▲"
        case .likeDecending:
            return "♥️▼"
        case .likeAscending:
            return "♥️▲"
        }
    }
}

struct DailyView: View {
    @ObservedResults(Item.self) var items
    @Binding var path: [Item]
    @Binding var selectionChartType: StatsType
    
    //絞り込み条件のプロパティ
    @State var isShowFilterSheet = false
    @State var isEnablePublishDateFliter = false
    @State var startDate = Date()
    @State var endDate = Date()
    @State var selectionContentTypes: Set<ContentType> = [.text, .talk, .image, .sound, .movie]
    
    @State private var sortType: SortType = .viewDecending
    
    var selectedDate: Date
    
    var filteredItem: [Item] {
        //まずDashboardViewで選択した取得日時のデータに絞り込む
        items.filter { (item: Item) -> Bool in
            guard let stats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }) else {
                return false
            }
            let baseCondition = item.publishedAt <= stats.updatedAt
            
            // 投稿日フィルター
            let publishDateCondition: Bool
            if isEnablePublishDateFliter {
                publishDateCondition = (startDate...endDate).contains(item.publishedAt)
            } else {
                publishDateCondition = true
            }
            
            // ContentTypeフィルター
            let contentTypeCondition = selectionContentTypes.contains(item.type)
            
            // すべての条件がtrueのみフィルターを通す
            return baseCondition && publishDateCondition && contentTypeCondition
        }
    }
    
    var sortedItems: [Item] {
        filteredItem.sorted { (item1, item2) -> Bool in
            let stats1 = item1.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }
            let stats2 = item2.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }
            
            switch sortType {
            case .publishedAtNew:
                return item1.publishedAt > item2.publishedAt
                
            case .publishedAtOld:
                return item1.publishedAt < item2.publishedAt
                
            case .viewDecending:
                let readCount1 = stats1?.readCount ?? 0
                let readCount2 = stats2?.readCount ?? 0
                return readCount1 > readCount2
                
            case .viewAscending:
                let readCount1 = stats1?.readCount ?? 0
                let readCount2 = stats2?.readCount ?? 0
                return readCount1 < readCount2
                
            case .commentDecending:
                let commentCount1 = stats1?.commentCount ?? 0
                let commentCount2 = stats2?.commentCount ?? 0
                return commentCount1 > commentCount2
                
            case .commentAscending:
                let commentCount1 = stats1?.commentCount ?? 0
                let commentCount2 = stats2?.commentCount ?? 0
                return commentCount1 < commentCount2
                
            case .likeDecending:
                let likeCount1 = stats1?.likeCount ?? 0
                let likeCount2 = stats2?.likeCount ?? 0
                return likeCount1 > likeCount2
                
            case .likeAscending:
                let likeCount1 = stats1?.likeCount ?? 0
                let likeCount2 = stats2?.likeCount ?? 0
                return likeCount1 < likeCount2
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    HStack {
                        Text("ビュー")
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        Text(formattedString(from: totalCount(for: \.readCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(differenceString(for: \.readCount))
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
                        Text(formattedString(from: totalCount(for: \.commentCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(differenceString(for: \.commentCount))
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
                        Text(formattedString(from: totalCount(for: \.likeCount)))
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(differenceString(for: \.likeCount))
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
                            isShowFilterSheet.toggle()
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
                            Picker("並び替え", selection: $sortType) {
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
                            ForEach(sortedItems) { item in
                                NavigationLink(destination: ArticleDetailView(item: item, path: $path, selection: $selectionChartType)) {
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
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.readCount ?? 0))
                                        }
                                        .frame(width: 80)
                                        ZStack {
                                            AppConstants.BrandColor.comment.opacity(0.3)
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.commentCount ?? 0))
                                        }
                                        .frame(width: 50)
                                        ZStack {
                                            AppConstants.BrandColor.likeBackground
                                            Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.likeCount ?? 0))
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
            .navigationTitle("\(selectedDate, formatter: dateFormatter) 統計")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowFilterSheet) {
                FilterSelecterView(isShowFilterSheet: $isShowFilterSheet, isEnablePublishDateFliter: $isEnablePublishDateFliter, startDate: $startDate, endDate: $endDate, selectionContentTypes: $selectionContentTypes)
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
    
    private func totalCount<T: Numeric>(for keyPath: KeyPath<Stats, T>) -> T {
        filteredItem.map { $0.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?[keyPath: keyPath] ?? 0 }.reduce(0, +)
    }
    
    private func previousUpdatedAt(for stats: [Stats], currentUpdatedAt: Date) -> Date? {
        let previousStats = stats.filter { $0.updatedAt < currentUpdatedAt }
        return previousStats.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt
    }
    
    private func differenceCount<T: Numeric & Comparable>(for keyPath: KeyPath<Stats, T>) -> T? {
        let currentTotal = totalCount(for: keyPath)
        let previousTotal = filteredItem.map { item in
            guard let currentStats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }),
                  let previousDate = previousUpdatedAt(for: Array(item.stats), currentUpdatedAt: currentStats.updatedAt),
                  let previousStats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: previousDate) }) else {
                return T.zero
            }
            return previousStats[keyPath: keyPath]
        }.reduce(T.zero, +)
        return previousTotal == T.zero ? nil : currentTotal - previousTotal
    }
    
    private func differenceString<T: Numeric & Comparable>(for keyPath: KeyPath<Stats, T>) -> String {
        if let difference = differenceCount(for: keyPath) {
            return "(+\(formattedString(from: difference)))"
        } else {
            return "(-)"
        }
    }
    
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
