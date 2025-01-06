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

struct APIUserDetailResponse: Codable {
    let noteCount: Int
}

struct APIResponse<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    let data: DataOrError
    
    init(data: DataOrError) {
        self.data = data
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<APIResponse<T>.CodingKeys> = try decoder.container(keyedBy: APIResponse<T>.CodingKeys.self)
        self.data = try container.decode(DataOrError.self, forKey: APIResponse<T>.CodingKeys.data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<APIResponse<T>.CodingKeys> = encoder.container(keyedBy: APIResponse<T>.CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}

enum DataOrError: Codable {
    case success(APIUserDetailResponse)
    case error(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let userData = try? container.decode(APIUserDetailResponse.self) {
            print("DataOrError: .success(\(userData)")
            self = .success(userData)
            
        } else if let errorMessage = try? container.decode(String.self) {
            print("DataOrError: .failure(\(errorMessage)")
            self = .error(errorMessage)
            
        } else {
            throw NAError.decoding(.decodingFailed(
                DecodingError.dataCorruptedError(in: container, debugDescription: "Data was neither valid user data nor error message")
            ))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success(let userData):
            try container.encode(userData)
        case .error(let message):
            try container.encode(message)
        }
    }
}
