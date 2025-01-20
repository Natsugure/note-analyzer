//
//  CustomAlertView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/18.
//

import SwiftUI

struct AlertEntity {
    enum ActionButtonStyle {
        case single(text: String, action: (() -> Void)?, role: ButtonRole?)
        case double(actionText: String, action: (()-> Void)?, actionRole: ButtonRole?, calcelAction: (() -> Void)?, cancelRole: ButtonRole?)
    }
    
    let id = UUID()
    let title: String
    let message: String
    let buttonStyle: ActionButtonStyle
    
    init(singleButtonAlert title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil, role: ButtonRole? = nil) {
        self.title = title
        self.message = message ?? ""
        self.buttonStyle = .single(text: actionText ?? "OK", action: action, role: role)
    }
    
    init(doubleButtonAlert title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, cancelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil) {
        let cancelButtonRole: ButtonRole?
        
        // 1つ以上のButtonにButtonRole.destructiveが指定されているときに、他にButtonRole.cancelが指定されているButtonがないと自動的にCancelボタンが生成されてしまう。
        // それを防ぐために、actionRoleに.destructiveが指定されているときは、自動的にcancelRoleに.cancelが入るようにする。
        if actionRole == .destructive {
            cancelButtonRole = .cancel
        } else {
            cancelButtonRole = cancelRole
        }
        
        self.title = title
        self.message = message ?? ""
        self.buttonStyle = .double(
            actionText: actionText ?? "OK",
            action: action,
            actionRole: actionRole,
            calcelAction: cancelAction,
            cancelRole: cancelButtonRole
        )
    }
}

extension AlertEntity: Equatable {
    static func == (lhs: AlertEntity, rhs: AlertEntity) -> Bool {
        lhs.id == rhs.id
    }
}

struct CustomAlertView: ViewModifier {
    @State var isPresented = false
    @Binding var object: AlertEntity?
    
    func body(content: Content) -> some View {
        content.alert(
            object?.title ?? "",
            isPresented: $isPresented,
            presenting: object,
            actions: {
                ActionView(buttonStyle: $0.buttonStyle)
            }, message: {
                Text($0.message)
            }
        )
        .onChange(of: object) {
            guard let _ = object else { return }
            isPresented = true
        }
    }
    
    struct ActionView: View {
        let buttonStyle: AlertEntity.ActionButtonStyle
        
        var body: some View {
            switch buttonStyle {
            case let .single(text, action, role):
                Button(text, role: role, action: action ?? {})
                
            case let .double(actionText, action, actionRole, cancelAction, cancelRole):
                Button("キャンセル", role: cancelRole, action: cancelAction ?? {})
                Button(actionText, role: actionRole, action: action ?? {})
            }
        }
    }
}

extension View {
    func customAlert(object: Binding<AlertEntity?>) -> some View {
        modifier(CustomAlertView(object: object))
    }
}
    
//    var model: AlertModel {
//        switch button {
//        case .single(let text, let action):
//            return AlertModel(
//                title: title,
//                messageView: AlertModel.MessageView(message: message),
//                actionView: AlertModel.ActionView(kind: .single(text: text, action: action))
//            )
//            
//        case .double(let text, let action, let actionRole, let cancelAction, let cancelRole):
//            let cancelButtonRole: ButtonRole?
//            // 1つ以上のButtonにButtonRole.destructiveが指定されているときに、他にButtonRole.cancelが指定されているButtonがないと自動的にCancelボタンが生成されてしまう。
//            // それを防ぐために、actionRoleに.destructiveが指定されているときは、自動的にcancelRoleに.cancelが入るようにする。
//            if actionRole == .destructive {
//                cancelButtonRole = .cancel
//            } else {
//                cancelButtonRole = cancelRole
//            }
//            
//            return AlertModel(
//                title: title,
//                messageView: AlertModel.MessageView(message: message),
//                actionView: AlertModel.ActionView(
//                    kind: .double(
//                        text: text,
//                        action: action,
//                        actionRole: actionRole,
//                        cancelAction: cancelAction,
//                        cancelRole: cancelButtonRole
//                    )
//                )
//            )
//        }
//    }

//struct AlertModel {
//    var title: String
//    var messageView: MessageView?
//    var actionView: ActionView
//    
//    struct MessageView: View {
//        var message: String
//        
//        var body: some View {
//            Text(message)
//        }
//    }
//
//    struct ActionView: View {
//        var kind: Kind
//        
//        enum Kind {
//            case single(text: String, action: (() -> Void)? = nil)
//            case double(text: String, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, cancelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil)
//        }
//        
//        var body: some View {
//            switch kind {
//            case .single(let text, let action):
//                Button(text, action: action ?? {})
//                
//            case .double(let text, let action, let actionRole, let cancelAction, let cancelRole):
//                Button("キャンセル", role: cancelRole, action: cancelAction ?? {})
//                Button(text, role: actionRole, action: action ?? {})
//            }
//        }
//    }
//}



//class AlertObject: ObservableObject {
//    @Published var isPresented: Bool = false
//    @Published var model: Model?
//    
//    struct Model {
//        var title: String
//        var messageView: MessageView?
//        var actionView: ActionView
//    }
//    
//    struct MessageView: View {
//        var message: String
//        
//        var body: some View {
//            Text(message)
//        }
//    }
//    
//    struct ActionView: View {
//        var kind: Kind
//        
//        enum Kind {
//            case single(text: String, action: (() -> Void)? = nil)
//            case double(text: String, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, cancelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil)
//        }
//        
//        var body: some View {
//            switch kind {
//            case .single(let text, let action):
//                Button(text, action: action ?? {})
//                
//            case .double(let text, let action, let actionRole, let cancelAction, let cancelRole):
//                Button("キャンセル", role: cancelRole, action: cancelAction ?? {})
//                Button(text, role: actionRole, action: action ?? {})
//            }
//        }
//    }
//    
////    func showAlert(entity: AlertEntity) {
////        model = entity.model
////        isPresented = true
////    }
////    
//    func showSingle(title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil) {
//        print("showSignle")
//        self.model = Model(title: title,
//                           messageView: (message != nil) ? MessageView(message: message!) : nil,
//                           actionView: ActionView(kind: .single(text: actionText ?? "OK", action: action))
//        )
//        
//            self.isPresented = true
//    }
//    
//    func showDouble(title: String, message: String?, actionText: String? = nil, action: (() -> Void)? = nil, actionRole: ButtonRole? = nil, calcelAction: (() -> Void)? = nil, cancelRole: ButtonRole? = nil) {
//        
//        let cancelButtonRole: ButtonRole?
//        // 1つ以上のButtonにButtonRole.destructiveが指定されているときに、他にButtonRole.cancelが指定されているButtonがないと自動的にCancelボタンが生成されてしまう。
//        // それを防ぐために、actionRoleに.destructiveが指定されているときは、自動的にcancelRoleに.cancelが入るようにする。
//        if actionRole == .destructive {
//            cancelButtonRole = .cancel
//        } else {
//            cancelButtonRole = cancelRole
//        }
//        
//        self.model = Model(
//            title: title,
//            messageView: (message != nil) ? MessageView(message: message!) : nil,
//            actionView: ActionView(
//                kind: .double(
//                    text: actionText ?? "OK",
//                    action: action,
//                    actionRole: actionRole,
//                    cancelAction: calcelAction,
//                    cancelRole: cancelButtonRole
//                )
//            )
//        )
//        
//        self.isPresented = true
//    }
//}

//struct CustomAlertView: ViewModifier {
//    @ObservedObject var alertObject: AlertObject
//    @Binding var isPresented: Bool
//    
//    func body(content: Content) -> some View {
//        content.alert(
//            alertObject.model?.title ?? "",
//            isPresented: $alertObject.isPresented,
//            presenting: alertObject.model
//        ) {
//            $0.actionView
//        } message: {
//            $0.messageView
//        }
//    }
//}

//extension View {
    //    func customAlert(for alertObject: AlertObject, isPresented: Binding<Bool>) -> some View {
    //        modifier(CustomAlertView(alertObject: alertObject, isPresented: isPresented))
    //    }
//}
