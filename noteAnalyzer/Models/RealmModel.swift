//
//  RealmModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import Foundation
import RealmSwift

final class Item: Object, Identifiable {
    @Persisted(primaryKey: true) var id: Int
    
    @Persisted var title: String
    @Persisted var type: ContentType
    @Persisted var publishedAt: Date
    @Persisted var stats: RealmSwift.List<Stats>
}

final class Stats: Object, Identifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    
    @Persisted var updatedAt: Date
    @Persisted var readCount: Int
    @Persisted var likeCount: Int
    @Persisted var commentCount: Int
    
    @Persisted(originProperty: "stats") var item: LinkingObjects<Item>
}

enum PreviewData {
    static var realm: Realm {
        let realm = try! Realm(configuration: .init(inMemoryIdentifier: "PreviewData.realm"))
        
        try! realm.write {
            realm.deleteAll()
        }
        
        try! realm.write {
            Self.items.forEach { item in
                realm.add(item)
            }
        }
        
        return realm
    }
}

extension PreviewData {
    private static var items: [Item] {
        let calendar = Calendar.current
        let mockUpdateAt = calendar.date(from: DateComponents(year: 2024, month: 7, day: 7))!
        
        var result: [Item] = []
        
        for i in 1...5 {
            let mockItem = Item()
            mockItem.id = i
            mockItem.title = "Sample Item 123456789012345678901234567890"
            mockItem.type = .text
            mockItem.publishedAt = calendar.date(byAdding: .day, value: -i, to: mockUpdateAt)!
            
            let mockStats = Stats()
            mockStats.id = UUID().uuidString
            mockStats.updatedAt = mockUpdateAt
            mockStats.readCount = i * 10000
            mockStats.likeCount = i * 100
            mockStats.commentCount = i
            
            mockItem.stats.append(mockStats)
            
            result.append(mockItem)
        }
        
        return result
    }
}
