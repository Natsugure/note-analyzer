//
//  RealmManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import Foundation
import RealmSwift

class RealmManager {
    private var realm: Realm?
        
    private func getRealm() -> Realm {
         if let realm = self.realm {
             return realm
         } else {
             do {
                 let realm = try Realm()
                 self.realm = realm
                 return realm
             } catch {
                 fatalError("Failed to initialize Realm on RealmManager: \(error)")
             }
         }
     }
    
    func updateStats(stats: [APIStatsResponse.APIStatsItem], publishedDate: [APIContentsResponse.APIContentItem]) throws {
        let updateDateTime = Date()
        let realm = getRealm()
        
        try realm.write {
            for stat in stats {
                if let existingItem = realm.object(ofType: Item.self, forPrimaryKey: stat.id) {
                    try updateExistingItem(existingItem, with: stat, at: updateDateTime)
                } else {
                    try createNewItem(in: realm, from: stat, publishedDate: publishedDate, at: updateDateTime)
                }
            }
        }
        print("Stats saved to Realm")
    }
    
    private func updateExistingItem(_ item: Item, with stat: APIStatsResponse.APIStatsItem, at date: Date) throws {
        let newStats = createStats(from: stat, at: date)
        item.stats.append(newStats)
    }
    
    private func createNewItem(in realm: Realm, from stat: APIStatsResponse.APIStatsItem, publishedDate: [APIContentsResponse.APIContentItem], at date: Date) throws {
        let newItem = Item()
        newItem.id = stat.id
        newItem.title = stat.type == .talk ? stat.body ?? "" : stat.name ?? "（不明なタイトル）"
        newItem.type = stat.type
        
        if let publishedAt = publishedDate.first(where: { $0.id == stat.id })?.publishAt {
            let dateFormatter = ISO8601DateFormatter()
            if let newValue = dateFormatter.date(from: publishedAt) {
                newItem.publishedAt =  newValue
            } else {
                throw NAError.realm(.publishedDateNotFound)
            }

        } else {
            throw NAError.realm(.publishedDateNotFound)
        }
        
        let newStats = createStats(from: stat, at: date)
        newItem.stats.append(newStats)
        
        realm.add(newItem)
    }
    
    private func createStats(from stat: APIStatsResponse.APIStatsItem, at date: Date) -> Stats {
        let newStats = Stats()
        newStats.updatedAt = date
        newStats.readCount = stat.readCount
        newStats.likeCount = stat.likeCount
        newStats.commentCount = stat.commentCount
        return newStats
    }
    
    func getItem() -> Results<Item> {
        let realm = getRealm()
        return realm.objects(Item.self)
    }
    
    func deleteAll() throws {
        let realm = getRealm()
        try realm.write {
            realm.deleteAll()
        }
    }
}
