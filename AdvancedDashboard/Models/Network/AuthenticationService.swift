//
//  AuthenticationService.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/24.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func authenticate(cookies: [HTTPCookie]) async throws
    func reauthorize(cookies: [HTTPCookie]) async throws
    func getCookies() throws -> [HTTPCookie]
    func clearAuthentication() throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    private let authManager = AuthenticationManager()
    private let networkService: NetworkServiceProtocol
    private let transformer = NoteDataTransformer()
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func authenticate(cookies: [HTTPCookie]) async throws {
        // saveUserDetails内で実際にAPIにログインできることを確認してから、KeychainにCookieを保存する。
        try await saveUserProfiles(cookies: cookies)
        try authManager.saveAuthCookies(cookies: cookies)
    }
    
    func reauthorize(cookies: [HTTPCookie]) async throws {
        try await verifySameUser(cookies: cookies)
        try authManager.saveAuthCookies(cookies: cookies)
    }
    
    private func saveUserProfiles(cookies: [HTTPCookie]) async throws {
        AppConfig.urlname = try await fetchUrlName(cookies: cookies)
        AppConfig.userId = try await fetchUserId(urlName: AppConfig.urlname, cookies: cookies)
    }
    
    private func verifySameUser(cookies: [HTTPCookie]) async throws {
        let urlName = try await fetchUrlName(cookies: cookies)
        let fetchedUserId = try await fetchUserId(urlName: urlName, cookies: cookies)
        
        guard AppConfig.userId == fetchedUserId else {
            throw NAError.auth(.loginCredentialMismatch)
        }
        
        AppConfig.urlname = urlName
    }
    
    private func fetchUserId(urlName: String, cookies: [HTTPCookie]) async throws -> Int {
        let urlString = "https://note.com/api/v2/creators/\(urlName)"
        let fetchedData = try await networkService.fetchData(url: urlString, cookies: cookies)
        let response: APIResponse<APIUserDetailResponse> = try transformer.decodeAPIResponse(fetchedData)
        switch response.data {
        case .success(let userData):
            return userData.id
            
        case .error(let message):
            throw NAError.decoding(.userNotFound(message))
        }
    }
    
    private func fetchUrlName(cookies: [HTTPCookie]) async throws -> String {
        let urlString = "https://note.com/api/v1/stats/pv?filter=all&page=1&sort=pv"
        let fetchedData = try await networkService.fetchData(url: urlString, cookies: cookies)
        let results: APIStatsResponse = try transformer.decodeAPIResponse(fetchedData)
        
        let urlName = results.data.noteStats[0].user.urlname
        
        return urlName
    }
    
    func getCookies() throws -> [HTTPCookie] {
        authManager.getCookies()
    }
        
    func clearAuthentication() throws {
        try authManager.clearAuthentication()
    }
}
