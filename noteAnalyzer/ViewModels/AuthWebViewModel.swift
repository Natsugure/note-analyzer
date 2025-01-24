//
//  AuthWebViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/09.
//

import SwiftUI
import WebKit

@MainActor
class AuthWebViewModel: ObservableObject, WebViewModelProtocol {
    @Published var isPresented = true
    @Published var didFinishLogin = false
    var urlString: String = "" {
        didSet {
            if urlString == AppConstants.URL.topPage {
                didFinishLogin = true
                isPresented = false
            }
        }
    }
    
    private(set) var webView: WKWebView
    
    init() {
        self.webView = WKWebView()
        
        loadAuthUrl()
    }
    
    func loadAuthUrl() {
        let urlString = "https://note.com/login"
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
