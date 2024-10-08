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

    
