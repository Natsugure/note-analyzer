//
//  SettingsViewModel.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/12.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var alertEntity: AlertEntity?
    @Published var url: URL?
    @Published var isPresentedAuthWebView = false
    @Published var isPresentedProgressView = false
    @Published var shouldShowOnboardingView = false
    @Published var didFinishLoginOnAuthWebView = false
    
    private let authService: AuthenticationServiceProtocol
    private var authWebViewModel: AuthWebViewModel?
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(authService: AuthenticationServiceProtocol, apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.authService = authService
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    func openContactUsPage() {
        let contactFormURLString = "https://forms.gle/Tceg32xcH8avj8qy5"
        
        alertEntity = .init(
            doubleButtonAlert: "",
            message: "お問い合わせフォームを外部ブラウザで開きます。\nよろしいですか？",
            action: {
                self.url = URL(string: contactFormURLString)
            }
        )
    }
    
    func openHowToUse() {
        let howToUsePageURLString = "https://github.com/Natsugure/note-analyzer/blob/master/USAGE.md"
        
        alertEntity = .init(
            doubleButtonAlert: "",
            message: "使い方の説明ページを外部ブラウザで開きます。\nよろしいですか？",
            action: {
                self.url = URL(string: howToUsePageURLString)
            }
        )
    }
    
    func reauthorize() async {
        isPresentedAuthWebView = true
    }
    
    func checkAuthentication(cookies: [HTTPCookie]) async {
        isPresentedProgressView = true
        
        do {
            try await authService.reauthorize(cookies: cookies)
            
            isPresentedProgressView = false
            alertEntity = .init(singleButtonAlert: "再認証が完了しました。", message: nil)
        } catch {
            print(error)
            let title = "認証エラー"
            let message: String
            
            if let naError = error as? NAError {
                message = naError.userMessage
            } else if let keychainError = error as? KeychainError {
                message = "認証データの保存中にエラーが発生しました。\(keychainError.localizedDescription)"
            } else {
                message = "不明なエラーが発生しました。"
            }
            
            isPresentedProgressView = false
            try? await Task.sleep(for: .seconds(0.2))
            alertEntity = .init(singleButtonAlert: title, message: message)
        }
    }
    
    func confirmClearData() {
        alertEntity = .init(
            doubleButtonAlert: "すべてのデータを消去",
            message: "\n●これまで取得した統計データ\n●noteへのログイン情報\n\nこれらがすべて消去され、アプリが初期状態に戻ります。\nこの操作は取り消すことができません。\n\n消去を実行しますか？",
            actionText: "消去する",
            action: {
                Task {
                    await self.clearAllDataButtonAction()
                }
            },
            actionRole: .destructive
        )
    }
    
    private func clearAllDataButtonAction() async {
        do {
            try await self.clearAllData()
            
            alertEntity = .init(
                singleButtonAlert: "消去完了",
                message: "すべてのデータの消去が完了しました。初期設定画面に戻ります。",
                action: {
                    self.shouldShowOnboardingView = true
                }
            )
        } catch {
            handleClearAllDataError(error)
        }
    }

    private func clearAllData() async throws {
        try apiClient.deleteAllComponents()
        try realmManager.deleteAll()
        
        AppConfig.deleteUserInfo()
        AppConfig.isCompletedInitialSetup = false
    }
    
    private func handleClearAllDataError(_ error: Error) {
        print(error)
        let title = "初期化エラー"
        let detail: String
        
        switch error {
        case let keyChainError as KeychainError:
            detail = "処理中にエラーが発生しました。\n 認証情報の消去に失敗しました。\(keyChainError.localizedDescription)"
            
        case let naError as NAError:
            detail = naError.userMessage
            
        default:
            detail = "不明なエラーが発生しました。"
        }
        
        alertEntity = .init(singleButtonAlert: title, message: detail)
    }
    
    //MARK: - Property and Method Only for DEBUG Session
#if DEBUG
    @Published var isDemoMode = AppConfig.isDemoMode
    
    func changeDemoModeKey() async {
        do {
            AppConfig.isDemoMode.toggle()
            print("appConfig.isDemoMode: \(AppConfig.isDemoMode)")
            try await clearAllData()
            showRestartAlert()
        } catch {
            handleClearAllDataError(error)
        }
    }
    
    func showRestartAlert() {
        alertEntity = .init(
            singleButtonAlert: "アプリの再起動が必要",
            message: "デモモードの設定を反映するには、アプリの再起動が必要です。",
            actionText: "再起動する",
            action: {
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    exit(0)
                }
            }
        )
    }
#endif
}
