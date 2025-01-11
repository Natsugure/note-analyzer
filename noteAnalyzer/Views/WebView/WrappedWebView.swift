//
//  WebView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/07/07.
//

import SwiftUI
import WebKit

@MainActor //プロトコルに付与しておけば、準拠したクラスにも適用される
protocol WebViewModelProtocol: ObservableObject {
    var webView: WKWebView { get }
    var urlString: String { get set } // 実装時には必ず`@Published`を付ける
}

struct WrappedWebView<ViewModel>: UIViewRepresentable where ViewModel: WebViewModelProtocol {
    @ObservedObject var viewModel: ViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        viewModel.webView.navigationDelegate = context.coordinator
        return viewModel.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

extension WrappedWebView {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WrappedWebView
        
        init(_ parent: WrappedWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let urlString = webView.url?.absoluteString {
                parent.viewModel.urlString = urlString
            }
        }
    }
}
