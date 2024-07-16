//
//  ContentsData.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/08.
//

import Foundation

enum ContentType: String, Codable {
    case text = "TextNote"
    case talk = "TalkNote"
    case image = "ImageNote"
    case movie = "MovieNote"
    
    init(_ value: String) {
        guard let contentType = ContentType(rawValue: value) else {
            preconditionFailure("Undefined note type")
        }
        self = contentType
    }
}

struct Results: Decodable {
    let data: ItemData
}

struct ItemData: Codable {
    let note_stats: [Contents]
    let last_page: Bool
}

struct Contents: Codable, Identifiable {
    var id: Int
    var name: String?
    var body: String?
    var type: ContentType {
        didSet {
            if type == .talk {
                name = body
            }
        }
    }
    var read_count: Int
    var like_count: Int
    var comment_count: Int
    
//    var id: String
//    var key: String
//    var name: String
//    var type: String
//    var read_count: String
//    var like_count: String
//    var comment_count: String
}
