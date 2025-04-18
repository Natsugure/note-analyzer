//
//  DateUtils.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/05.
//

import Foundation

struct DateUtils {
    static let calendar = Calendar(identifier: .gregorian)
    
    static let formatterToyyyyMMddHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter
    }()
}

extension Calendar {
    /// `Date`型を受け取り、その日の23時59分59秒に再設定した新しい`Date`型を返す。
    func endOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
