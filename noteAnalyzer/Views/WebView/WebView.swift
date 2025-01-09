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
    typealias CompletionHandler = ([HTTPCookie]) -> Void

    let urlString: String?
    private let observable = WebViewURLObservable()
    
    var completion: CompletionHandler?
    
//    @ObservedObject var viewModel: OnboardingViewModel
//    @Binding var isPresented: Bool
    
    init(urlString: String?, completion: @escaping CompletionHandler) {
        self.urlString = urlString
//        self.viewModel = viewModel
        
        self.completion = completion
    }
    
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
                // TODO: このやり方が本当に最適か？ 関係ないViewのViewModelに依存しているのはおかしくないか？あと、Cookieの取得に失敗しててもこれじゃわからないぞ。
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
                    guard let self = self else { return }
                    
                    parent.completion?(cookies)
                    
//                    parent.viewModel.checkAuthentication(cookies: cookies)
                }
            }
        }
    }
}

private class WebViewURLObservable: ObservableObject {
    @Published var instance: NSKeyValueObservation?
}
