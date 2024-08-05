//
//  RealmManager.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/21.
//

import Foundation
import RealmSwift

class RealmManager {
    private let realm: Realm
    
    init() throws {
        realm = try Realm()
    }
    
    func updateStats(stats: [FetchedStatsData.Content], publishedDate: [FetchedContentsData.Content]) throws {
        let updateDateTime = Date()
        
        try realm.write {
            for stat in stats {
                if let existingItem = realm.object(ofType: Item.self, forPrimaryKey: stat.id) {
                    try updateExistingItem(existingItem, with: stat, at: updateDateTime)
                } else {
                    try createNewItem(from: stat, publishedDate: publishedDate, at: updateDateTime)
                }
            }
        }
        print("Stats saved to Realm")
    }
    
    private func updateExistingItem(_ item: Item, with stat: FetchedStatsData.Content, at date: Date) throws {
        let newStats = createStats(from: stat, at: date)
        item.stats.append(newStats)
    }
    
    private func createNewItem(from stat: FetchedStatsData.Content, publishedDate: [FetchedContentsData.Content], at date: Date) throws {
        let newItem = Item()
        newItem.id = stat.id
        newItem.title = stat.type == .talk ? stat.body ?? "" : stat.name ?? "（不明なタイトル）"
        newItem.type = stat.type
        
        if let publishedAt = publishedDate.first(where: { $0.id == stat.id })?.publishAt {
            let dateFormatter = ISO8601DateFormatter()
            if let newValue = dateFormatter.date(from: publishedAt) {
                newItem.publishedAt =  newValue
            } else {
                throw RealmError.publishedDateNotFound
            }

        } else {
            throw RealmError.publishedDateNotFound
        }
        
        let newStats = createStats(from: stat, at: date)
        newItem.stats.append(newStats)
        
        realm.add(newItem)
    }
    
    private func createStats(from stat: FetchedStatsData.Content, at date: Date) -> Stats {
        let newStats = Stats()
        newStats.updatedAt = date
        newStats.readCount = stat.readCount
        newStats.likeCount = stat.likeCount
        newStats.commentCount = stat.commentCount
        return newStats
    }
    
    func getItems() -> Results<Item>? {
        return realm.objects(Item.self)
    }
}

enum RealmError: Error {
    case publishedDateNotFound
}
