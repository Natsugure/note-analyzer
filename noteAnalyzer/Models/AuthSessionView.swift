//
//  AuthSessionView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/14.
//

import SwiftUI
import AuthenticationServices

struct AuthSessionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    var callback: (URL) -> Void
    
    let authURL = "https://note.com/login"
    let customURLScheme = "noteanalyzer"
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        guard let url = URL(string: authURL) else {
            return vc
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: customURLScheme) { callbackURL, error in
            if let callbackURL {
                callback(callbackURL)
            } else if let error {
                fatalError(error.localizedDescription)
            }
        }
        
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = context.coordinator
        session.start()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    var parent: AuthSessionView
    
    init(parent: AuthSessionView) {
        self.parent = parent
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
            fatalError("No windows in the application")
        }
        return window
    }
}
