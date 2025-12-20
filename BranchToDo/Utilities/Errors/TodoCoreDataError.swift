//
//  TodoCoreDataError.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/20/25.
//

import Foundation

public enum TodoCoreDataError: Error, Equatable {
    case notFound(id: Int32)
}

// Error messages for the user
extension TodoCoreDataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .notFound(_):
                return "The item could not be found"
        }
    }
}

extension TodoCoreDataError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .notFound(let id):
                return "Todo not found with id: \(id)"
        }
    }
}
