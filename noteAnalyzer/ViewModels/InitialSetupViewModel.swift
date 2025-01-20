//
//  InitialSetupViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/14.
//

import Foundation

@MainActor
class InitialSetupViewModel: ObservableObject {
    @Published var progressValue = 0.0
    @Published var isPresentedProgressView = false
    @Published var shouldShowCompleteInitialSetupView = false
    @Published var alertEntity: AlertEntity?
    
    private let apiClient: NoteAPIClient
    let realmManager: RealmManager
    
    init(apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.apiClient = apiClient
        self.realmManager = realmManager
        
        apiClient.$progressValue.assign(to: &$progressValue)
    }
    
    func fetchStats() async {
        isPresentedProgressView = true
        
        do {
            let (stats, publishedDateArray) = try await apiClient.requestFetch()
            
            try realmManager.updateStats(stats: stats, publishedDate: publishedDateArray)
            
            AppConfig.isCompletedInitialSetup = true
            isPresentedProgressView = false
            shouldShowCompleteInitialSetupView = true
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print(error.localizedDescription)
        
        let title: String
        let message: String
        
        if let naError = error as? NAError {
            switch naError {
            case .network(let detail):
                title = "ネットワークエラー"
                message = detail.userMessage
            case .auth(let detail):
                title = "認証エラー"
                message = detail.userMessage
            case .decoding(let detail):
                title = "取得エラー"
                message = detail.userMessage
            case .realm(let detail):
                title = "データベースエラー"
                message = detail.userMessage
            }
        } else {
            title = "不明なエラー"
            message = "不明なエラーが発生しました。"
        }
        
        alertEntity = .init(singleButtonAlert: title, message: message)
    }
}
