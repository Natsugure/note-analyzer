//
//  NetworkRequester.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/09.
//

import Foundation

class NetworkRequester {
    private let authManager: AuthenticationProtocol
    private let networkService: NetworkServiceProtocol
    private let apiFetcher: NoteAPIFetcher
    
    init(authManager: AuthenticationProtocol, networkService: NetworkServiceProtocol, apiFetcher: NoteAPIFetcher) {
        self.authManager = authManager
        self.networkService = networkService
        self.apiFetcher = apiFetcher
    }
}
