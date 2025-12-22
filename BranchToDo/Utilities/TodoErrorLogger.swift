//
//  TodoErrorLogger.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import os
import Foundation

class TodoErrorLogger {
    // Use modern OSLog Logger API
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BranchToDo", category: "Networking")
    
    static func logError(_ error: Error) {
        logger.error("🚨 TODO: \(error.localizedDescription, privacy: .public)")
    }
    
    static func logMessage(_ message: String) {
        logger.info("⚠️ TODO: \(message)")
    }
}

