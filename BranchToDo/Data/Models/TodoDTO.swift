//
//  TodoDTO.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation
import CoreData

struct TodoDTO: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

extension Todo {
    public static func makeStub(context: NSManagedObjectContext) -> Todo {
        let todo = Todo(context: context)
        todo.id = Int32.randomInt32Id()
        todo.userId = Int32.randomInt32Id()
        todo.title = "Todo 1"
        todo.createdAt = Date.now
        todo.completed = false
        return todo
    }
}
