//
//  CustomAlertView.swift
//  AdvancedDashboard
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
    @Binding var entity: AlertEntity?
    
    func body(content: Content) -> some View {
        content.alert(
            entity?.title ?? "",
            isPresented: $isPresented,
            presenting: entity,
            actions: {
                ActionView(buttonStyle: $0.buttonStyle)
            }, message: {
                Text($0.message)
            }
        )
        .onChange(of: entity) {
            guard let _ = entity else { return }
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
    func customAlert(entity: Binding<AlertEntity?>) -> some View {
        modifier(CustomAlertView(entity: entity))
    }
}
