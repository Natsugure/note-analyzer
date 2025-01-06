//
//  Calendar+DateFormatter.swift
//  noteAnalyzer
//
//  Created by akizora on 2025/01/05.
//

import Foundation

enum DateFormat {
    case yyyyMMddHHmm
    
    var formatter: DateFormatter {
        switch self {
            case .yyyyMMddHHmm:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            return formatter
        }
    }
}

extension String {
    func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.date(from: dateString)!
    }
}


