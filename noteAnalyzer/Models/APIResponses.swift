//
//  APIResponses.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/08.
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
    
    var name: String {
        switch self {
        case .text: return "通常記事"
        case .talk: return "つぶやき"
        case .sound: return "音声"
        case .image: return "画像"
        case .movie: return "動画"
        }
    }
}

struct APIStatsResponse: Codable {
    let data: APIStatsData
    
    struct APIStatsData: Codable {
        let noteStats: [APIStatsItem]
        let lastPage: Bool
        let lastCalculateAt: String
    }
    
    struct APIStatsItem: Codable, Identifiable {
        var id: Int
        var name: String?
        var body: String?
        var type: ContentType
        var readCount: Int
        var likeCount: Int
        var commentCount: Int
        var user: APIUserInfo
    }
    
    struct APIUserInfo: Codable {
        var urlname: String
    }
}

struct APIContentsResponse: Codable {
    let data: APIContentsData
    
    struct APIContentsData: Codable {
        let contents: [APIContentItem]
        let isLastPage: Bool
    }
    
    struct APIContentItem: Codable, Identifiable {
        let id: Int
        let publishAt: String
    }
}

struct APIErrorResponse: Codable {
    let error: APIError
    
    struct APIError: Codable {
        let code: String
        let message: String
    }
}
