//
//  DemoAuthWebViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/11.
//

import SwiftUI

class DemoAuthWebViewModel: AuthWebViewModel {
    override init() {
        super.init()
        
        super.didFinishLogin = true
        super.isPresented = false
    }
}
