//
//  NoteDataTransformer.swift
//  AdvancedDashboard
//
//  Created by Natsugure on 2025/01/12.
//

import Foundation

struct NoteDataTransformer {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
//    func parseUserDetailJSON(_ data: Data) throws -> APIResponse<APIUserDetailResponse> {
//        return try decoder.decode(APIResponse<APIUserDetailResponse>.self, from: data)
//    }
//    
//    func parseStatsJSON(_ data: Data) throws -> APIStatsResponse {
//        let results: APIStatsResponse = try decodeAPIResponse(data)
//        
//        return results
//    }
//    
//    func parseContentsJSON(_ data: Data) throws -> APIContentsResponse {
//        let results: APIContentsResponse = try decodeAPIResponse(data)
//        
//        return results
//    }
//    
//    func parseSearchUserJSON(_ data: Data) throws -> APISearchUserResponse {
//        let results: APISearchUserResponse = try decodeAPIResponse(data)
//        
//        return results
//    }
    
    func decodeAPIResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            // まず、APIStatsResponseとしてデコードを試みる
            return try decoder.decode(T.self, from: data)
        } catch {
            // デコードに失敗した場合、エラーレスポンスとしてデコードを試みる
            do {
                let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                if errorResponse.error.code == "auth" {
                    throw NAError.auth(.authenticationFailed)
                } else {
                    throw NAError.decoding(.decodingFailed(error))
                }
            } catch {
                // エラーレスポンスのデコードにも失敗した場合
                throw error
            }
        }
    }
}
