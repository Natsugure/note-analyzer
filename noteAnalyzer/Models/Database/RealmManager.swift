//
//  RealmManager.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/21.
//

import Foundation
import RealmSwift

class RealmManager {
    init() {
        let config = Realm.Configuration(
            schemaVersion: 2, // スキーマバージョンをインクリメント
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
                        if let oldPublishedAt = oldObject?["publishedAt"] as? String {
                            let dateFormatter = ISO8601DateFormatter()
                            if let date = dateFormatter.date(from: oldPublishedAt) {
                                newObject?["publishedAt"] = date
                            }
                        }
                    }
                }
            }
        )
        // Realmのデフォルト設定を更新
        Realm.Configuration.defaultConfiguration = config
    }
    
    func updateStats(stats: [APIStatsResponse.APIStatsItem], publishedDate: [APIContentsResponse.APIContentItem]) throws {
        let updateDateTime = Date()
        let realm = try! Realm()
        
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
        let realm = try! Realm()
        return realm.objects(Item.self)
    }
    
    func getStatsResults() -> Results<Stats> {
        let realm = try! Realm()
        return realm.objects(Stats.self)
    }
    
    func deleteAll() throws {
        let realm = try! Realm()
        try realm.write {
            realm.deleteAll()
        }
    }
}
