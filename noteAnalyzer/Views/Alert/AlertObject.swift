//
//  AlertObject.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/18.
//

import SwiftUI

class AlertObject: ObservableObject {
    @Published var isShow: Bool = false
    @Published var model: Model?
    
    struct Model {
        var title: String
        var messageView: MessageView?
        var actionView: ActionView
    }
    
    struct MessageView: View {
        var message: String
        
        var body: some View {
            Text(message)
        }
    }
    
    struct ActionView: View {
        var kind: Kind
        
        enum Kind {
            case single(text: String, action: (() -> Void)? = nil)
            case double(text: String, action: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil)
        }
        
        var body: some View {
            switch kind {
            case .single(let text, let action):
                Button(text, action: action ?? {})
                
            case .double(let text, let action, let cancelAction):
                Button("キャンセル", action: cancelAction ?? {})
                Button(text, action: action ?? {})
            }
        }
    }
    
    func showSingle(title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil) {
        self.model = Model(title: title,
                           messageView: (message != nil) ? MessageView(message: message!) : nil,
                           actionView: ActionView(kind: .single(text: actionText ?? "OK", action: action))
        )
        
        self.isShow.toggle()
    }
    
    func showDouble(title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil, calcelAction: (() -> Void)? = nil) {
        self.model = Model(title: title,
                           messageView: (message != nil) ? MessageView(message: message!) : nil,
                           actionView: ActionView(kind: .double(text: actionText ?? "OK", action: action, cancelAction: calcelAction))
        )
        
        self.isShow.toggle()
    }
}

struct CustomAlertView: ViewModifier {
    @ObservedObject var alertObject: AlertObject
    
    func body(content: Content) -> some View {
        content
            .alert(
                alertObject.model?.title ?? "",
                isPresented: $alertObject.isShow,
                presenting: alertObject.model
            ) {
                $0.actionView
            } message: {
                $0.messageView
            }
    }
}

extension View {
    func customAlert(for alertObject: AlertObject) -> some View {
        modifier(CustomAlertView(alertObject: alertObject))
    }
}
