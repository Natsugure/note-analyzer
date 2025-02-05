//
//  AuthWebViewModel.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/09.
//

import SwiftUI
import WebKit

@MainActor
class AuthWebViewModel: ObservableObject, WebViewModelProtocol {
    @Published var shouldExecuteCompletionHandler = false
    var urlString: String = "" {
        didSet {
            if urlString == AppConstants.URL.topPage {
                shouldExecuteCompletionHandler = true
            }
        }
    }
    
    typealias CompletionHandler = ([HTTPCookie]) -> Void
    private let completionHandler: CompletionHandler
    
    private(set) var webView: WKWebView
    
    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
        self.webView = WKWebView()
        
        loadAuthUrl()
    }
    
    func executeCompletionHandler() async {
        let cookies = await webView.configuration.websiteDataStore.httpCookieStore.allCookies()
        await webView.configuration.websiteDataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast)
        
        completionHandler(cookies)
    }
    
    func loadAuthUrl() {
        let urlString = "https://note.com/login"
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
