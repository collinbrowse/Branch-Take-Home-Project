//
//  TodoErrorLogger.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import os
import Foundation

class TodoErrorLogger {
    // Use modern OSLog Logger API which supports interpolation
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BranchToDo", category: "Networking")
    
    static func logError(_ error: Error) {
        // Use modern OSLog Logger API which supports interpolation
        logger.error("🚨 Todo error: \(error.localizedDescription, privacy: .public)")
    }
    
    static func logMessage(_ message: String) {
        os_log("⚠️ Todo message", message)
    }
}

