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
//        loadHTMLContent(<#T##content: String##String#>, into: <#T##WKWebView#>)
//        uiView.uiDelegate = context.coordinator
//        uiView.navigationDelegate = context.coordinator
//        observable.instance = uiView.observe(\WKWebView.url, options: .new) { view, change in
//            if let url = view.url {
//                let stringUrl = url.absoluteString
//                if stringUrl == "https://note.com/" {
////                    NetworkManager().getCookies(uiView)
//                }
//            }
//        }
        
        if let safeString = urlString {
            if let url = URL(string: safeString) {
                let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    guard let data = data else {
                        print("No data.")
                        return
                    }
                    DispatchQueue.main.async {
                        if let string = String(data: data, encoding: .utf8) {
                            print(string)
                        }
                        uiView.load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: url)
                    }
                }
//                uiView.load(request)
                task.resume()
            }
        }
    }
    
    func loadHTMLContent(_ content: String, into webView: WKWebView) {
        // 文字列をUTF-8でエンコード
        guard let data = content.data(using: .utf8) else {
            print("Failed to encode content.")
            return
        }

        // データをUTF-8としてロード
        webView.load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: URL(string: "https://example.com")!)
    }
}

extension WebView {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }
        

    }
}

private class WebViewURLObservable: ObservableObject {
    @Published var instance: NSKeyValueObservation?
}
