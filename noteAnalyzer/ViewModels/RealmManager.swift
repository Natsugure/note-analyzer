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
    
    func updateStats(stats: [FetchedStatsData.Content], publishedDate: [FetchedContentsData.Content]) {
        let updateDateTime = Date()
        
        do {
            try realm.write {
                for stat in stats {
                    if let existingItem = realm.object(ofType: Item.self, forPrimaryKey: stat.id) {
                        // 既存のItemが見つかった場合、新しいStatsを追加
                        let newStats = Stats()
                        newStats.updatedAt = updateDateTime
                        newStats.readCount = stat.readCount
                        newStats.likeCount = stat.likeCount
                        newStats.commentCount = stat.commentCount
                        existingItem.stats.append(newStats)
                    } else {
                        // 新しいItemを作成
                        let newItem = Item()
                        newItem.id = stat.id
                        if stat.type == .talk {
                            newItem.title = stat.body!
                        } else {
                            newItem.title = stat.name!
                        }
                        newItem.type = stat.type
                        
                        //記事一覧から取得した投稿日をItemに追記
                        if let publishedAt = publishedDate.first(where: { $0.id == stat.id }) {
                            newItem.publishedAt = publishedAt.publishAt
                        } else {
                            preconditionFailure("Published date not found")
                        }
                        
                        // 新しいStatsを作成して追加
                        let newStats = Stats()
                        newStats.updatedAt = updateDateTime
                        newStats.readCount = stat.readCount
                        newStats.likeCount = stat.likeCount
                        newStats.commentCount = stat.commentCount
                        newItem.stats.append(newStats)
                        
                        // 新しいItemをRealmに追加
                        realm.add(newItem)
                    }
                }
            }
            print("Stats saved to Realm")
        } catch {
            print("Error saving stats to Realm: \(error)")
        }
    }
    
    func getItems() -> Results<Item>? {
        return realm.objects(Item.self)
    }
}
