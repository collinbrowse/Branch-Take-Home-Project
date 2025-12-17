//
//  NetworkFactory.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation

class TodoNetworkFactory {
    
    // MARK: - Execute Request
    /// The responseMapper should handle caching the response, if desired
    public static func fetch(
        session: URLSession,
        requestConfig: JSONRequestConfig
    ) async throws -> (Data, URLResponse) {
        
        guard let request = JSONRequestConfig.buildRequest(with: requestConfig) else {
            throw TodoNetworkError.invalidRequestStructure
        }
                
        return try await URLSession.shared.data(for: request)
    }
}

