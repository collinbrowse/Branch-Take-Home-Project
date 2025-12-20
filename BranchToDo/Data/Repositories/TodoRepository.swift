//
//  TodoRepository.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//

import CoreData
import SwiftUI

protocol TodoRepositoryProtocol {
    @MainActor func createEmptyTodo() throws -> NSManagedObjectID
    @MainActor func getTodo(objectId: NSManagedObjectID) throws -> Todo
    @MainActor func updateTodoTitle(objectId: NSManagedObjectID, title: String) throws
    @MainActor func toggleCompletion(objectId: NSManagedObjectID) throws
    @MainActor func deleteTodo(objectId: NSManagedObjectID) throws
    @MainActor func save() throws
    func batchUpsert(_ dtos: [TodoDTO]) async throws
    func fetchDemoTodosAndSave() async throws
    
}

class CoreDataRepository: TodoRepositoryProtocol {
    
    private let container: NSPersistentContainer
    private let userId: Int32
    
    init(container: NSPersistentContainer, userId: Int32) {
        self.container = container
        self.userId = userId
    }
    
    /// Add a todo to the view context with default values
    /// Use when creating an empty todo for the user
    /// - Returns: The id of the new todo
    @MainActor
    func createEmptyTodo() throws -> NSManagedObjectID {
        let context = container.viewContext
        let newTodo = Todo(context: context)
        newTodo.completed = false
        newTodo.createdAt = Date.now
        newTodo.id = Int32.randomInt32Id()
        newTodo.title = ""
        newTodo.userId = userId
        return newTodo.objectID
    }
    
    /// Find and return a todo from the view context
    /// - Parameters:
    ///   - objectId: The id of the todo
    /// - Returns: The NSManagedObject - Todo
    @MainActor
    func getTodo(objectId: NSManagedObjectID) throws -> Todo {
        let context = container.viewContext
        return try context.existingObject(with: objectId) as! Todo
    }
    
    /// Update the title of a todo in the view context
    /// DOES NOT save the view context
    /// - Parameters:
    ///   - objectId: the id of the todo
    ///   - title: the new title (or name) of the todo
    @MainActor
    func updateTodoTitle(objectId: NSManagedObjectID, title: String) throws {
        let context = container.viewContext
        let todo = try context.existingObject(with: objectId) as! Todo
        todo.title = title
    }
    
    /// Toggle the compled value of a todo in the view context
    /// DOES NOT save the view context
    /// - Parameters:
    ///   - objectId: the id of the todo
    @MainActor
    func toggleCompletion(objectId: NSManagedObjectID) throws {
        let context = container.viewContext
        let todo = try context.existingObject(with: objectId) as! Todo
        todo.completed.toggle()
    }
    
    /// Remove a todo item with an id in the view context
    /// DOES NOT save the view context
    /// - Parameters:
    ///   - objectId: the id of the todo
    @MainActor
    func deleteTodo(objectId: NSManagedObjectID) throws {
        let context = container.viewContext
        let todo = try context.existingObject(with: objectId)
        context.delete(todo)
    }
    
    /// Save the view context
    @MainActor
    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Batch upsert todos from the network to Core Data
    /// If one upsert fails, operation stops and state is rolled back
    /// - Parameters:
    ///   - dtos: An array of the data transfer object for a todo
    func batchUpsert(_ dtos: [TodoDTO]) async throws {
        // Early return if empty
        guard !dtos.isEmpty else {
            return
        }
        
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    
                    // Extract all IDs for batch lookup
                    let ids = dtos.map { Int32($0.id) }
                    
                    // Batch fetch all existing todos in one query
                    let request: NSFetchRequest<Todo> = Todo.fetchRequest()
                    request.predicate = NSPredicate(format: "id IN %@", ids)
                    let existingTodos = try context.fetch(request)
                    
                    // Create a dictionary for O(1) lookup
                    var existingTodosDict: [Int32: Todo] = [:]
                    for todo in existingTodos {
                        existingTodosDict[todo.id] = todo
                    }
                    
                    // Upsert all todos
                    for dto in dtos {
                        let id = Int32(dto.id)
                        let todo: Todo
                        
                        if let existingTodo = existingTodosDict[id] {
                            // Update existing todo
                            todo = existingTodo
                        } else {
                            // Create new todo
                            todo = Todo(context: context)
                            todo.id = id
                        }
                        
                        // Update properties
                        todo.completed = dto.completed
                        todo.createdAt = nil // Network todos don't have createdAt
                        todo.title = dto.title
                        todo.userId = Int32(dto.userId)
                    }
                    
                    // Single save - if this fails, all changes are rolled back
                    try context.save()
                    continuation.resume()
                } catch {
                    // If any error occurs, the context automatically rolls back
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Calls the network for a list of demo Todos
    /// Saves to Core Data
    func fetchDemoTodosAndSave() async throws {
        let todos = try await TodoAPIService.fetchTodos()
        try await batchUpsert(todos)
    }
}
