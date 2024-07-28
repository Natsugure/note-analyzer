//
//  ContentsData.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/08.
//

import Foundation
import RealmSwift

enum ContentType: String, Codable, RawRepresentable, PersistableEnum {
    case text = "TextNote"
    case talk = "TalkNote"
    case sound = "SoundNote"
    case image = "ImageNote"
    case movie = "MovieNote"
    
    init(_ value: String) {
        guard let contentType = ContentType(rawValue: value) else {
            preconditionFailure("Undefined note type")
        }
        self = contentType
    }
}

struct FetchedStatsData: Codable {
    let data: ItemData
    
    struct ItemData: Codable {
        let noteStats: [Content]
        let lastPage: Bool
        let lastCalculateAt: String
    }
    
    struct Content: Codable, Identifiable {
        var id: Int
        var name: String?
        var body: String?
        var type: ContentType
        var readCount: Int
        var likeCount: Int
        var commentCount: Int
        var user: UserURLName
    }
    
    struct UserURLName: Codable {
        var urlname: String
    }
}

struct FetchedContentsData: Codable {
    let data: ItemData
    
    struct ItemData: Codable {
        let contents: [Content]
        let isLastPage: Bool
    }
    
    struct Content: Codable, Identifiable {
        let id: Int
        let publishAt: String
    }
}
