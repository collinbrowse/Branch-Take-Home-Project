//
//  TodoErrorHandler.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation
import OSLog

final class TodoErrorHandler {
    
    // MARK: - Methods
    static func handleError(_ error: Error, url: URL) -> TodoNetworkError {
        
        if let urlError = error as? URLError {
            switch urlError.code {
                case URLError.notConnectedToInternet,
                    URLError.networkConnectionLost,
                    URLError.dataNotAllowed,
                    URLError.internationalRoamingOff:
                    return .notConnectedToInternet
                case URLError.timedOut:
                    return .networkServerFailure(code: urlError.code.rawValue, url: url)
                default:
                    break
            }
        }
        
        // Use modern OSLog Logger API which supports interpolation
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BranchToDo", category: "Networking")
        logger.error("Todo error: \(error.localizedDescription, privacy: .public) | url: \(url.absoluteString, privacy: .public)")
       
        return .genericError(error)
    }
}
