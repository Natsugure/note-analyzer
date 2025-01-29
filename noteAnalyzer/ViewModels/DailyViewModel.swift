//
//  DailyViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/16.
//

import Foundation
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

struct StatsSummary {
    let totalRead: Int
    let readDifference: String
    let totalComment: Int
    let commentDifference: String
    let totalLike: Int
    let likeDifference: String
}

@MainActor
final class DailyViewModel: ObservableObject {
    var selectedDate: Date
    
    @Published private(set) var listItems: [Item] = []
    @Published private(set) var statsSummary: StatsSummary?
    @Published var isPresentedProgressView = false
    @Published var isShowFilterSheet = false
    @Published var isEnablePublishDateFliter = false
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var selectionContentTypes: Set<ContentType> = [.text, .talk, .image, .sound, .movie]
    @Published var sortType: SortType = .viewDecending
    
    private let realmManager: RealmManager
    private var baseResults: Results<Item>!
    private var filteredResults: Results<Item>!
    
    init(date: Date, realmManager: RealmManager) {
        self.selectedDate = date
        self.realmManager = realmManager
        
        baseResults = realmManager.getItem()
        updateSummaryAndList()
    }
    
    func updateSummaryAndList() {
        Task {
            filteredResults = await filterItemResults()
            await applySort()
            await updateSummary()
        }
    }
    
    private func changeProgressViewState() async {
        isPresentedProgressView.toggle()
    }
    
    private func updateSummary() async {
        statsSummary = StatsSummary(
                    totalRead: totalCount(for: \.readCount),
                    readDifference: differenceString(for: \.readCount),
                    totalComment: totalCount(for: \.commentCount),
                    commentDifference: differenceString(for: \.commentCount),
                    totalLike: totalCount(for: \.likeCount),
                    likeDifference: differenceString(for: \.likeCount)
                )
    }
    
    private func filterItemResults() async -> Results<Item> {
        return baseResults.where { item -> Query<Bool> in
            let baseCondition = item.stats.updatedAt == selectedDate && item.publishedAt <= selectedDate
            
            // 投稿日フィルター
            let publishDateCondition: Query<Bool>
            if isEnablePublishDateFliter {
                publishDateCondition = item.publishedAt.contains(startDate...endDate)
            } else {
                publishDateCondition = item.publishedAt.contains(Date.distantPast...Date.distantFuture)
            }
            
            // ContentTypeフィルター
            let contentTypeCondition = item.type.in(selectionContentTypes)
            
            // すべての条件がtrueのみフィルターを通す
            return baseCondition && publishDateCondition && contentTypeCondition
        }
    }
    
    func applySort() async {
        listItems = filteredResults.sorted { (item1, item2) -> Bool in
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
    
    func totalCount<T: Numeric>(for keyPath: KeyPath<Stats, T>) -> T {
        filteredResults.map { $0.stats.first { Calendar.current.isDate($0.updatedAt, inSameDayAs: self.selectedDate) }?[keyPath: keyPath] ?? 0 }.reduce(0, +)
    }
    
    private func previousUpdatedAt(for stats: [Stats], currentUpdatedAt: Date) -> Date? {
        let previousStats = stats.filter { $0.updatedAt < currentUpdatedAt }
        return previousStats.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt
    }
    
    private func differenceCount<T: Numeric & Comparable>(for keyPath: KeyPath<Stats, T>) -> T? {
        let currentTotal = totalCount(for: keyPath)
        let previousTotal = filteredResults.map { item in
            guard let currentStats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: self.selectedDate) }),
                  let previousDate = self.previousUpdatedAt(for: Array(item.stats), currentUpdatedAt: currentStats.updatedAt),
                  let previousStats = item.stats.first(where: { Calendar.current.isDate($0.updatedAt, inSameDayAs: previousDate) }) else {
                return T.zero
            }
            return previousStats[keyPath: keyPath]
        }.reduce(T.zero, +)
        return previousTotal == T.zero ? nil : currentTotal - previousTotal
    }
    
    func differenceString<T: Numeric & Comparable>(for keyPath: KeyPath<Stats, T>) -> String {
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

