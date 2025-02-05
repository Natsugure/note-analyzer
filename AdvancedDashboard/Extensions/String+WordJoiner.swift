//
//  String+WordJoiner.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/06.
//

import Foundation

extension String {
    func insertWordJoiner() -> String {
        let wordJoiner = "\u{2060}"
        let characters = self.map { String($0) }
        let modifiedString = characters.joined(separator: wordJoiner)
        
        return modifiedString
    }
}
