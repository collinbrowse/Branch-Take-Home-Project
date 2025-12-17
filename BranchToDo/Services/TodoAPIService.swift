//
//  APIService.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation

class TodoAPIService {
    
    static func fetchTodos() async throws -> [TodoDTO] {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let requestConfig = JSONRequestConfig(retries: 2)
        
        let (data, response) = try await TodoNetworkFactory.fetch(
            session: session,
            requestConfig: requestConfig
        )
        
        return try TodoResponseDecoder.decodeResponse(data: data, response: response)
    }
}
