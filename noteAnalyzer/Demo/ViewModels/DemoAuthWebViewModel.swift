//
//  DemoAuthWebViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/11.
//

import SwiftUI

class DemoAuthWebViewModel: AuthWebViewModel {
    override init(authManager: AuthenticationProtocol) {
        super.init(authManager: authManager)
        
        Task {
            await checkAuthentication()
        }
    }
    
    override func checkAuthentication() async {
        super.showInitialSetupView()
    }
}
