//
//  MockRepository.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/20/25.
//

import Foundation

/// Mock implementation of TodoRepositoryProtocol for testing ViewModel behavior
/// without requiring actual Core Data persistence or network calls.
/// 
/// Uses pure in-memory storage with domain models - no Core Data dependency.
class MockRepository: TodoRepositoryProtocol {
    
    private let userId: Int32
    
    // In-memory storage for todos (keyed by id)
    private var todos: [Int32: TodoItem] = [:]
    
    // Storage for batch upserted todos (from network)
    private var networkTodos: [Int32: TodoDTO] = [:]
    
    // Error injection for testing error scenarios
    var shouldThrowErrorOnCreateEmptyTodo = false
    var shouldThrowErrorOnGetTodo = false
    var shouldThrowErrorOnUpdateTitle = false
    var shouldThrowErrorOnToggleCompletion = false
    var shouldThrowErrorOnDelete = false
    var shouldThrowErrorOnSave = false
    var shouldThrowErrorOnFetchDemoTodos = false
    var shouldThrowErrorOnBatchUpsert = false
    
    var errorToThrow: Error?
    
    // Delay for async operations (for testing loading states)
    var asyncDelay: TimeInterval = 0.1
    
    // Call tracking for verification
    var createEmptyTodoCallCount = 0
    var getTodoCallCount = 0
    var updateTitleCallCount = 0
    var toggleCompletionCallCount = 0
    var deleteTodoCallCount = 0
    var saveCallCount = 0
    var fetchDemoTodosCallCount = 0
    var batchUpsertCallCount = 0
    
    init(userId: Int32) {
        // Container parameter kept for API compatibility but not used
        self.userId = userId
    }
    
    @MainActor
    func createEmptyTodo() throws -> TodoItem {
        createEmptyTodoCallCount += 1
        
        if shouldThrowErrorOnCreateEmptyTodo {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error creating empty todo"])
        }
        
        // Create domain model (no Core Data needed!)
        let todoItem = TodoItem(
            id: Int32.randomInt32Id(),
            title: "",
            completed: false,
            createdAt: Date.now,
            userId: userId
        )
        
        todos[todoItem.id] = todoItem
        
        return todoItem
    }
    
    @MainActor
    func getTodo(id: Int32) throws -> TodoItem {
        getTodoCallCount += 1
        
        if shouldThrowErrorOnGetTodo {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "Mock error getting todo"])
        }
        
        guard let todoItem = todos[id] else {
            throw TodoCoreDataError.notFound(id: id)
        }
        
        return todoItem
    }
    
    @MainActor
    func updateTodoTitle(id: Int32, title: String) throws {
        updateTitleCallCount += 1
        
        if shouldThrowErrorOnUpdateTitle {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "Mock error updating title"])
        }
        
        guard var todoItem = todos[id] else {
            throw TodoCoreDataError.notFound(id: id)
        }
        
        // Update our in-memory domain model (no Core Data)
        todoItem.title = title
        todos[id] = todoItem
    }
    
    @MainActor
    func toggleCompletion(id: Int32) throws {
        toggleCompletionCallCount += 1
        
        if shouldThrowErrorOnToggleCompletion {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "Mock error toggling completion"])
        }
        
        guard var todoItem = todos[id] else {
            throw TodoCoreDataError.notFound(id: id)
        }
        
        // Update our in-memory domain model (no Core Data)
        todoItem.completed.toggle()
        todos[id] = todoItem
    }
    
    @MainActor
    func deleteTodo(id: Int32) throws {
        deleteTodoCallCount += 1
        
        if shouldThrowErrorOnDelete {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 5, userInfo: [NSLocalizedDescriptionKey: "Mock error deleting todo"])
        }
        
        guard todos[id] != nil else {
            throw TodoCoreDataError.notFound(id: id)
        }
        
        // Remove from our in-memory dictionary (no Core Data)
        todos.removeValue(forKey: id)
    }
    
    @MainActor
    func save() throws {
        saveCallCount += 1
        
        if shouldThrowErrorOnSave {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 6, userInfo: [NSLocalizedDescriptionKey: "Mock error saving"])
        }
        
        // In a real mock, save() would be a no-op since we're not persisting
        // But we track the call for verification purposes
        // No Core Data operations needed
    }
    
    func batchUpsert(_ dtos: [TodoDTO]) async throws {
        batchUpsertCallCount += 1
        
        // Simulate async delay
        try await Task.sleep(nanoseconds: UInt64(asyncDelay * 1_000_000_000))
        
        if shouldThrowErrorOnBatchUpsert {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 7, userInfo: [NSLocalizedDescriptionKey: "Mock error in batch upsert"])
        }
        
        guard !dtos.isEmpty else {
            return
        }
        
        // Store DTOs in simple in-memory dictionary (no Core Data)
        for dto in dtos {
            networkTodos[Int32(dto.id)] = dto
        }
        
        // No Core Data operations - just in-memory storage
    }
    
    func fetchDemoTodosAndSave() async throws {
        fetchDemoTodosCallCount += 1
        
        // Simulate async delay
        try await Task.sleep(nanoseconds: UInt64(asyncDelay * 1_000_000_000))
        
        if shouldThrowErrorOnFetchDemoTodos {
            throw errorToThrow ?? NSError(domain: "MockRepository", code: 8, userInfo: [NSLocalizedDescriptionKey: "Mock network error fetching demo todos"])
        }
        
        // Create some mock demo todos
        let mockTodos: [TodoDTO] = [
            TodoDTO(userId: Int(userId), id: 1, title: "Mock Todo 1", completed: false),
            TodoDTO(userId: Int(userId), id: 2, title: "Mock Todo 2", completed: true),
            TodoDTO(userId: Int(userId), id: 3, title: "Mock Todo 3", completed: false)
        ]
        
        try await batchUpsert(mockTodos)
    }
    
    // MARK: - Helper methods for testing
    
    /// Reset all error flags, call counts, and stored data
    func reset() {
        shouldThrowErrorOnCreateEmptyTodo = false
        shouldThrowErrorOnGetTodo = false
        shouldThrowErrorOnUpdateTitle = false
        shouldThrowErrorOnToggleCompletion = false
        shouldThrowErrorOnDelete = false
        shouldThrowErrorOnSave = false
        shouldThrowErrorOnFetchDemoTodos = false
        shouldThrowErrorOnBatchUpsert = false
        errorToThrow = nil
        asyncDelay = 0.1
        
        createEmptyTodoCallCount = 0
        getTodoCallCount = 0
        updateTitleCallCount = 0
        toggleCompletionCallCount = 0
        deleteTodoCallCount = 0
        saveCallCount = 0
        fetchDemoTodosCallCount = 0
        batchUpsertCallCount = 0
        
        // Clear all stored data (no Core Data to clear)
        todos.removeAll()
        networkTodos.removeAll()
    }
    
    /// Get the count of todos in memory (user-created todos only)
    var todoCount: Int {
        todos.count
    }
    
    /// Get the count of network todos (from batchUpsert)
    var networkTodoCount: Int {
        networkTodos.count
    }
}
