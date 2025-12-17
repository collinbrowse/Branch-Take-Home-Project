//
//  TodoResponseDecoder.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation
import OSLog

public final class TodoResponseDecoder {
    
    static func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            TodoErrorLogger.logError(TodoNetworkError.networkInvalidResponse)
            throw TodoNetworkError.networkInvalidResponse
        }
        
        switch httpResponse.statusCode {
            case 200..<300:
                return try decodeData(data)
            case 400...499:
                TodoErrorLogger.logError(TodoNetworkError.networkClientFailure(code: httpResponse.statusCode, url: httpResponse.url))
                throw TodoNetworkError.networkClientFailure(code: httpResponse.statusCode, url: httpResponse.url)
            case 500...599:
                TodoErrorLogger.logError(TodoNetworkError.networkServerFailure(code: httpResponse.statusCode, url: httpResponse.url))
                throw TodoNetworkError.networkServerFailure(code: httpResponse.statusCode, url: httpResponse.url)
            default:
                TodoErrorLogger.logError(TodoNetworkError.networkUnknownStatusCode(code: httpResponse.statusCode, url: httpResponse.url?.absoluteString ?? ""),)
                throw TodoNetworkError.networkUnknownStatusCode(code: httpResponse.statusCode, url: httpResponse.url?.absoluteString ?? "")
                
        }
    }
    
    static func decodeData<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            TodoErrorLogger.logError(TodoNetworkError.networkResponseDecodingFailure(error))
            throw TodoNetworkError.networkResponseDecodingFailure(error)
        }
    }
}
