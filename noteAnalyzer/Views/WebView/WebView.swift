//
//  WebView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    @Binding var isPresented: Bool
    var viewModel: NoteViewModel
    let urlString: String?
    private let observable = WebViewURLObservable()
    
    var observer: NSKeyValueObservation? {
        observable.instance
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
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
            if webView.url?.absoluteString == "https://note.com/" {
                parent.viewModel.checkAuthentication(webView: webView)
            }
        }
    }
}

private class WebViewURLObservable: ObservableObject {
    @Published var instance: NSKeyValueObservation?
}
