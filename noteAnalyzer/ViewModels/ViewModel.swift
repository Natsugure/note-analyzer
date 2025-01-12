//
//  ViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/17.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var progressValue = 0.0
    
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.apiClient = apiClient
        self.realmManager = realmManager
        
        apiClient.$progressValue.assign(to: &$progressValue)
    }
    
    func getStats() async throws {
        let (stats, publishedDateArray) = try await apiClient.requestFetch()
        
        try await MainActor.run {
            // TODO: DB書き込み処理のprogressValueはどう計算するか？コンテンツ数が少ないなら一瞬だが、1000記事を超えるような人だとどうか？
            // TODO: RealmManager内のエラー処理が定まっていないので、RealmManager内で定義する。
            try realmManager.updateStats(stats: stats, publishedDate: publishedDateArray)
        }
    }
    
    func verifyLoginConsistency() async throws {
//        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
//        
//        do {
//            let realmItems = try realmManager.getItemList()
//            if realmItems.isEmpty {
//                return
//            }
//            
//            let fetchedData = try await networkService.fetchData(url: urlString)
//            
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            let results = try decoder.decode(APIStatsResponse.self, from: fetchedData)
//            
//            let firstArticle = results.data.noteStats[0]
//            guard let _ = realmItems.first(where: { $0.id == firstArticle.id && $0.title == firstArticle.name }) else {
//                throw NAError.Auth.loginCredentialMismatch
//            }
//        } catch {
//            throw error
//        }
    }
    

}
