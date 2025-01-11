//
//  Constants.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/27.
//

import SwiftUI

struct AppConstants {
    struct URL {
        static let authUrl = "https://note.com/login"
        static let topPage = "https://note.com/"
    }
    
    struct BrandColor {
        static let read = Color(red: 105/255, green: 176/255, blue: 118/255)
        static let comment = Color(red: 105/255, green: 105/255, blue: 105/255)
        static let like = Color(red: 200/255, green: 44/255, blue: 85/255)
        static let likeBackground = Color(red: 246/255, green: 191/255, blue: 188/255)
    }
    
    struct ContentTypeImage {
        static let text = UIImage(systemName: "book.pages")
        static let talk = UIImage(systemName: "text.bubble.fill")
        static let sound = UIImage(systemName: "mic.fill")
        static let image = UIImage(systemName: "photo")
        static let movie = UIImage(systemName: "video.fill")
    }
    
//    struct UserDefaults {
//        static let authenticationConfigured = "authenticationConfigured"
//        static let lastCalculateAt = "lastCalculateAt"
//        static let urlname = "urlname"
//        static let contentsCount = "contentsCount"
//        
//        static let demoModekey = "demoModeKey"
//    }
}
