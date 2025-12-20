//
//  JSONRequestConfig.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation

struct JSONRequestConfig {
    /// the part after the domain
    var path: String = TodoConstants.todosPath
    var endpointURL: String = TodoConstants.apiURL
    var method: String = "GET"
    /// iOS 13+ prevents get request from having a body
    var body: [String: Any]?
    var headers: [String: String]?
    var retries: Int
    var cachePolicy: URLRequest.CachePolicy = .reloadRevalidatingCacheData
    
    var httpBody: Data? {
        guard let parameters = body else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
    
    var fullURL: URL? {
        return URL(string: endpointURL + path)
    }
    
    static func buildRequest(with requestConfig: JSONRequestConfig) -> URLRequest? {
        
        guard let url = requestConfig.fullURL else {
            TodoErrorLogger.logMessage("Did not create request url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = requestConfig.method
        request.allHTTPHeaderFields = requestConfig.headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = requestConfig.cachePolicy
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.httpBody = requestConfig.httpBody
        request.timeoutInterval = 10
        
        return request
    }
}
