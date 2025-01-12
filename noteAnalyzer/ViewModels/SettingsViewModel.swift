//
//  SettingsViewModel.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/12.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    private let apiClient: NoteAPIClient
    private let realmManager: RealmManager
    
    init(apiClient: NoteAPIClient, realmManager: RealmManager) {
        self.apiClient = apiClient
        self.realmManager = realmManager
    }
    
    func logout() async throws {
        do {
            try apiClient.deleteAllComponents()
            
            // TODO: ここで再スローしてるのおかしくない？AuthenticationManager内でNAErrorに置き換えるべきかも
        } catch KeychainError.unexpectedStatus(let status) {
            throw KeychainError.unexpectedStatus(status)
        } catch {
            throw error
        }
    }

    func clearAllData() async throws {
        do {
            try apiClient.deleteAllComponents()
            try realmManager.deleteAll()
            
            AppConfig.deleteUserInfo()
            
            // TODO: ここで再スローしてるのおかしくない？AuthenticationManager内でNAErrorに置き換えるべきかも
        } catch KeychainError.unexpectedStatus(let status) {
            print("Keychain error occurred. \n code: \(status), description: \(status.description)")
            throw KeychainError.unexpectedStatus(status)
        } catch {
            print("Failed to delete all data: \(error)")
            throw error
        }
    }
}
