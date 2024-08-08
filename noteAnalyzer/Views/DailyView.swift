//
//  DailyView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/04.
//

import SwiftUI
import RealmSwift

enum SortType {
    case publishedAt
    case title
    case view
    case comment
    case like
}

struct DailyView: View {
    @ObservedResults(Item.self) var items
    @Binding var path: [Item]
    @Binding var selection: StatsType
    
    @State private var sortType: SortType = .view
    
    var selectedDate: Date
    
    var sortedItems: [Item] {
        items.filter { item in
            guard let stats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }) else {
                return false
            }
            return item.publishedAt <= stats.updatedAt
        }
        .sorted { (item1, item2) -> Bool in
            let stats1 = item1.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }
            let stats2 = item2.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }
            
            switch sortType {
            case .publishedAt:
                return item1.publishedAt > item2.publishedAt
                
            case .title:
                return item1.title < item2.title
                
            case .view:
                let readCount1 = stats1?.readCount ?? 0
                let readCount2 = stats2?.readCount ?? 0
                return readCount1 > readCount2
                
            case .comment:
                let commentCount1 = stats1?.commentCount ?? 0
                let commentCount2 = stats2?.commentCount ?? 0
                return commentCount1 > commentCount2
                
            case .like:
                let likeCount1 = stats1?.likeCount ?? 0
                let likeCount2 = stats2?.likeCount ?? 0
                return likeCount1 > likeCount2
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    VStack {
                        Text("ビュー")
                            .frame(alignment: .top)
                        Text(formattedString(from: totalCount(for: \.readCount)))
                            .font(.system(size: 24, weight: .semibold))
                        Text(differenceString(for: \.readCount))
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                    .background(K.BrandColor.read.opacity(0.5))
                    
                    HStack {
                        VStack {
                            Text("コメント")
                            Text(formattedString(from: totalCount(for: \.commentCount)))
                                .font(.system(size: 24, weight: .semibold))
                            Text(differenceString(for: \.commentCount))
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                        .background(K.BrandColor.comment.opacity(0.3))
                        
                        VStack {
                            Text("スキ")
                            Text(formattedString(from: totalCount(for: \.likeCount)))
                                .font(.system(size: 24, weight: .semibold))
                            Text(differenceString(for: \.likeCount))
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                        .background(K.BrandColor.likeBackground)
                    }
                }
                .padding()
                
                List {
                    Section(header:
                                HStack {
                        Text("投稿日").bold()
                            .frame(width: 45)
                            .onTapGesture {
                                sortType = .publishedAt
                            }
                        
                        Text("記事").bold()
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                sortType = .title
                            }
                        Text("ビュー").bold()
                            .frame(width: 60)
                            .onTapGesture {
                                sortType = .view
                            }
                        Text("コメント").bold()
                            .frame(width: 40)
                            .onTapGesture {
                                sortType = .comment
                            }
                        Text("スキ").bold()
                            .frame(width: 60)
                            .padding(.trailing, 27)
                            .onTapGesture {
                                sortType = .like
                            }
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
                                    VStack {
                                        Text(item.publishedAt, formatter: yearFormatter)
                                        Text(item.publishedAt, formatter: monthDayFormatter)
                                    }
                                    .frame(width: 45)
                                    Text(item.title)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 10)
                                    ZStack {
                                        K.BrandColor.read.opacity(0.5)
                                        Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.readCount ?? 0))
                                    }
                                    .frame(width: 60)
                                    ZStack {
                                        K.BrandColor.comment.opacity(0.3)
                                        Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.commentCount ?? 0))
                                    }
                                    .frame(width: 40)
                                    ZStack {
                                        K.BrandColor.likeBackground
                                        Text(String(item.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?.likeCount ?? 0))
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
            .navigationTitle("\(selectedDate, formatter: dateFormatter) 統計")
            .navigationBarTitleDisplayMode(.inline)
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
        items.map { $0.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: selectedDate) }?[keyPath: keyPath] ?? 0 }.reduce(0, +)
    }
    
    private func previousUpdatedAt(for stats: [Stats], currentUpdatedAt: Date) -> Date? {
        let previousStats = stats.filter { $0.updatedAt < currentUpdatedAt }
        return previousStats.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt
    }
    
    private func differenceCount<T: Numeric & Comparable>(for keyPath: KeyPath<Stats, T>) -> T? {
        let currentTotal = totalCount(for: keyPath)
        let previousTotal = items.map { item in
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

//#Preview {
//    DailyView()
//}
