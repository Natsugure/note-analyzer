//
//  AlertObject.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/18.
//

import SwiftUI

class AlertObject: ObservableObject {
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
            case double(text: String, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, cancelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil)
        }
        
        var body: some View {
            switch kind {
            case .single(let text, let action):
                Button(text, action: action ?? {})
                
            case .double(let text, let action, let actionRole, let cancelAction, let cancelRole):
                Button("キャンセル", role: cancelRole, action: cancelAction ?? {})
                Button(text, role: actionRole, action: action ?? {})
            }
        }
    }
    
    func showSingle(isPresented: Binding<Bool>, title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil) {
        self.model = Model(title: title,
                           messageView: (message != nil) ? MessageView(message: message!) : nil,
                           actionView: ActionView(kind: .single(text: actionText ?? "OK", action: action))
        )
        
        isPresented.wrappedValue = true
    }
    
    func showDouble(isPresented: Binding<Bool>, title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, calcelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil) {
        
        let cancelButtonRole: ButtonRole?
        // 1つ以上のButtonにButtonRole.destructiveが指定されているときに、他にButtonRole.cancelが指定されているButtonがないと自動的にCancelボタンが生成されてしまう。
        // それを防ぐために、actionRoleに.destructiveが指定されているときは、自動的にcancelRoleに.cancelが入るようにする。
        if actionRole == .destructive {
            cancelButtonRole = .cancel
        } else {
            cancelButtonRole = cancelRole
        }
        
        self.model = Model(title: title,
                           messageView: (message != nil) ? MessageView(message: message!) : nil,
                           actionView: ActionView(
                            kind: .double(
                                text: actionText ?? "OK",
                                action: action,
                                actionRole: actionRole,
                                cancelAction: calcelAction,
                                cancelRole: cancelButtonRole
                            ))
        )
        
        isPresented.wrappedValue = true
    }
}

struct CustomAlertView: ViewModifier {
    @ObservedObject var alertObject: AlertObject
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content.alert(
            alertObject.model?.title ?? "",
            isPresented: $isPresented,
            presenting: alertObject.model
        ) {
            $0.actionView
        } message: {
            $0.messageView
        }
    }
}

extension View {
    func customAlert(for alertObject: AlertObject, isPresented: Binding<Bool>) -> some View {
        modifier(CustomAlertView(alertObject: alertObject, isPresented: isPresented))
    }
}
