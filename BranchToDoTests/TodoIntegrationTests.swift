//
//  TodoIntegrationTests.swift
//  BranchToDoTests
//
//  Created by Collin Browse on 12/20/25.
//

import XCTest
@testable import BranchToDo
import CoreData

@MainActor
final class TodoIntegrationTests: TodoTests {
    
    override func setUpWithError() throws {
        try setupTestContainer()
        try setupTestRepository()
        viewModel = makeTestViewModel(repository: repository)
    }
    
    override func tearDownWithError() throws {
    }
    
    var coreDataRepository: CoreDataRepository {
        return repository as! CoreDataRepository
    }
    
    // MARK: - Flow 1: Create and Save Todo
    
    func testCreateAndSaveTodo_PersistsToCoreData() throws {
        // ARRANGE: Start editing to create empty todo
        viewModel.isEditing = true
        let todoId = try XCTUnwrap(viewModel.currentTodoId, "Todo ID should be set after creating empty todo")
        
        // ACT: Set title and finish editing
        viewModel.newTitle = "Buy Groceries"
        viewModel.isEditing = false
        
        // ASSERT: Verify todo persists in Core Data
        let context = container.viewContext
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        let todos = try context.fetch(request)
        
        XCTAssertEqual(todos.count, 1, "Should have one todo saved")
        let savedTodo = try XCTUnwrap(todos.first)
        XCTAssertEqual(savedTodo.title, "Buy Groceries", "Title should be saved correctly")
        XCTAssertFalse(savedTodo.completed, "Todo should not be completed")
        XCTAssertNotNil(savedTodo.createdAt, "Todo should have createdAt date")
        XCTAssertEqual(savedTodo.userId, TodoConstants.userId, "Todo should have correct userId")
    }
    
    // MARK: - Flow 2: Delete Todo
    
    func testDeleteTodo_RemovesFromCoreData() throws {
        // ARRANGE: Create and save a todo
        viewModel.isEditing = true
        let todoId = try XCTUnwrap(viewModel.currentTodoId)
        viewModel.newTitle = "Todo to Delete"
        viewModel.isEditing = false
        
        // Verify it exists
        let context = container.viewContext
        var request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        var todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 1, "Todo should exist before deletion")
        
        // ACT: Delete the todo
        viewModel.deleteTodo(id: todoId)
        
        // ASSERT: Verify todo is removed from Core Data
        request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 0, "Todo should be deleted from Core Data")
    }
    
    // MARK: - Flow 3: Toggle Completion
    
    func testToggleCompletion_PersistsState() throws {
        // ARRANGE: Create and save a todo
        viewModel.isEditing = true
        let todoId = try XCTUnwrap(viewModel.currentTodoId)
        viewModel.newTitle = "Todo to Toggle"
        viewModel.isEditing = false
        
        // Verify initial state
        let context = container.viewContext
        var request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        var todos = try context.fetch(request)
        let initialTodo = try XCTUnwrap(todos.first)
        XCTAssertFalse(initialTodo.completed, "Todo should start as not completed")
        
        // ACT: Toggle completion
        viewModel.toggleCompletion(id: todoId)
        
        // ASSERT: Verify state persists
        request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        todos = try context.fetch(request)
        let toggledTodo = try XCTUnwrap(todos.first)
        XCTAssertTrue(toggledTodo.completed, "Completion state should be toggled and persisted")
        
        // ACT: Toggle again
        viewModel.toggleCompletion(id: todoId)
        
        // ASSERT: Verify it toggles back
        request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        todos = try context.fetch(request)
        let toggledBackTodo = try XCTUnwrap(todos.first)
        XCTAssertFalse(toggledBackTodo.completed, "Completion should toggle back to false")
    }
    
    // MARK: - Flow 4: Create Empty Todo and Cancel
    
    func testCreateEmptyTodoAndCancel_DeletesFromCoreData() throws {
        // ARRANGE: Start editing to create empty todo
        viewModel.isEditing = true
        let todoId = try XCTUnwrap(viewModel.currentTodoId, "Todo ID should be set")
        
        // Verify empty todo was created in Core Data (before save)
        let context = container.viewContext
        var request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        var todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 1, "Empty todo should exist in context")
        
        // ACT: Finish editing without setting a title (cancels)
        viewModel.isEditing = false
        
        // ASSERT: Verify empty todo was deleted
        request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", todoId)
        todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 0, "Empty todo should be deleted when cancelled")
    }
}

