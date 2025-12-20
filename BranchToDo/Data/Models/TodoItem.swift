//
//  TodoItem.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/20/25.
//

import Foundation

/// Domain model representing a Todo item in the application.
/// This is independent of Core Data and external APIs.
struct TodoItem: Identifiable, Equatable {
    let id: Int32
    var title: String
    var completed: Bool
    var createdAt: Date?
    let userId: Int32
    
    init(
        id: Int32,
        title: String,
        completed: Bool = false,
        createdAt: Date? = nil,
        userId: Int32
    ) {
        self.id = id
        self.title = title
        self.completed = completed
        self.createdAt = createdAt
        self.userId = userId
    }
}

