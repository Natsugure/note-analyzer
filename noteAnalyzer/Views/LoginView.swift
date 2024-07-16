//
//  LoginView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/14.
//

import SwiftUI

struct LoginView: View {
    @State private var code: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("ログイン画面")
                    .font(.title)
                
                Spacer()
                
                if let code = self.code {
                    Text("ログイン済み")
                    Text("\(code)")
                } else {
                    Text("未ログイン")
                    AuthSessionView { callbackURL in
                        self.code = getCode(callbackURL: callbackURL)
                    }
                }
                
                Spacer()
                
            }
        }
    }
    
    func getCode(callbackURL: URL) -> String? {
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            return nil
        }
        if let codeValue = queryItems.first(where: { $0.name == "code"})?.value {
            print("Code value: \(codeValue)")
            return codeValue
        } else {
            return nil
        }
    }
}

#Preview {
    LoginView()
}
