//
//  WebView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/07.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let urlString: String?
    private let observable = WebViewURLObservable()
    
    var observer: NSKeyValueObservation? {
        observable.instance
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        uiView.navigationDelegate = context.coordinator
        observable.instance = uiView.observe(\WKWebView.url, options: .new) { view, change in
            if let url = view.url {
                let stringUrl = url.absoluteString
                if stringUrl == "https://note.com/" {
                    NetworkManager().getCookies(uiView)
                }
            }
        }
        
        if let safeString = urlString {
            if let url = URL(string: safeString) {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }
}

extension WebView {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            NetworkManager().getCookies(webView)
        }
    }
}

private class WebViewURLObservable: ObservableObject {
    @Published var instance: NSKeyValueObservation?
}
