//
//  DashboardViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/12.
//

import SwiftUI
import RealmSwift
import Combine

final class DashboardViewModel: ObservableObject {   
    @Published var progressValue = 0.0
    @Published var isPresentedProgressView = false
    
    private let apiClient: NoteAPIClient
    let realmManager: RealmManager
    
    init(apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.apiClient = apiClient
        self.realmManager = realmManager
        
        apiClient.$progressValue.assign(to: &$progressValue)
    }
    
    func getStats() async throws {
        await MainActor.run {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            
            withTransaction(transaction) {
                print("transaction true")
                isPresentedProgressView = true
            }
        }

        do {
            let (stats, publishedDateArray) = try await apiClient.requestFetch()
            
            try await MainActor.run {
                // TODO: DB書き込み処理のprogressValueはどう計算するか？コンテンツ数が少ないなら一瞬だが、1000記事を超えるような人だとどうか？
                // TODO: RealmManager内のエラー処理が定まっていないので、RealmManager内で定義する。
                try realmManager.updateStats(stats: stats, publishedDate: publishedDateArray)
            }
            
            await MainActor.run {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                withTransaction(transaction) {
                    print("transaction false")
                    isPresentedProgressView = false
                }
            }
        } catch {
            await MainActor.run {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                withTransaction(transaction) {
                    isPresentedProgressView = false
                }
            }
            throw error
        }
    }
}
