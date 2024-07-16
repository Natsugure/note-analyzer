//
//  Contents.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import Foundation
import RealmSwift

final class Item: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    
    @Persisted var title: String
    @Persisted var type: String
    @Persisted var published_at: Date
    @Persisted var stats: RealmSwift.List<Stats>
}

final class Stats: Object, Identifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    
    @Persisted var updated_at: Date
    @Persisted var view_count: Int
    @Persisted var like_count: Int
    @Persisted var comment_count: Int
    
    @Persisted(originProperty: "stats") var item: LinkingObjects<Item>
}
