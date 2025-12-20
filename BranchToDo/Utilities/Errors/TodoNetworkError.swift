//
//  Errors.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation

public enum TodoNetworkError: Error {
    case notConnectedToInternet
    case unknown
    case invalidRequestStructure
    case networkClientFailure(code: Int, url: URL?)
    case networkServerFailure(code: Int, url: URL?)
    case networkUnknownStatusCode(code: Int, url: String)
    case genericError(Error)
    case networkInvalidResponse
    case networkResponseDecodingFailure(Error)
}

// Error messages for the user
extension TodoNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .notConnectedToInternet:
                return "Oops! It looks like you're offline. Please check your connection and try again."
            case .unknown:
                return "There was an error. Please retry later"
            case .invalidRequestStructure:
                return "The network returned an invalid response"
            case .networkClientFailure(_, _):
                return "The network client failed"
            case .networkServerFailure(_, _):
                return "The network server failed"
            case .networkUnknownStatusCode(_, _):
                return "The network request failed with an unknown error"
            case .genericError(_):
                return "The network request failed"
            case .networkInvalidResponse:
                return "The network returned an invalid response"
            case .networkResponseDecodingFailure(_):
                return "There was an issue retrieving your data. Please try again"
        }
    }
}

extension TodoNetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .notConnectedToInternet:
                return "There is no network connection"
            case .unknown:
                return "There was an unkown error"
            case .invalidRequestStructure:
                return "Invalid Request Structure. Check your JSONRequestConfig.buildRequest"
            case .networkClientFailure(code: let code, url: let url):
                return "The network client failed. Code: \(code). URL: \(url?.absoluteString ?? "no url provided")"
            case .networkServerFailure(code: let code, url: let url):
                return "The server failed with the code: \(code) at url: \(url?.absoluteString ?? "N/A")"
            case .networkUnknownStatusCode(code: let code, url: let url):
                return "The network request failed with unknown status code. Code: \(code). URL: \(url)"
            case .genericError(let error):
                return "There was a generic error: \(error.localizedDescription)"
            case .networkInvalidResponse:
                return "Error: Invalid Network Response"
            case .networkResponseDecodingFailure(let error):
                return "Unable to decode network response. Error: \(error)"
        }
    }
}

