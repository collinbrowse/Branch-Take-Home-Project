//
//  CoreDataRepositoryTests.swift
//  BranchToDoTests
//
//  Created by Collin Browse on 12/20/25.
//

import XCTest
@testable import BranchToDo
import CoreData

@MainActor
final class CoreDataRepositoryTests: TodoTests {
    
    override func setUpWithError() throws {
        try setupTestContainer()
        try setupTestRepository()
    }
    
    override func tearDownWithError() throws {
    }
    
    // Convenience accessor for repository as CoreDataRepository
    var coreDataRepository: CoreDataRepository {
        return repository as! CoreDataRepository
    }
    
    // MARK: - Domain Model Conversion Tests
    
    func testCreateEmptyTodo_ReturnsValidTodoItem() throws {
        // ACT
        let todoItem = try coreDataRepository.createEmptyTodo()
        
        // ASSERT
        XCTAssertNotEqual(todoItem.id, 0, "Todo should have a valid ID")
        XCTAssertEqual(todoItem.title, "", "New todo should have empty title")
        XCTAssertFalse(todoItem.completed, "New todo should not be completed")
        XCTAssertNotNil(todoItem.createdAt, "New todo should have createdAt date")
        XCTAssertEqual(todoItem.userId, TodoConstants.userId, "Todo should have correct userId")
    }
    
    func testGetTodo_ConvertsToDomainModel() throws {
        // ARRANGE: Create a todo directly in Core Data
        let context = container.viewContext
        let testTodo = createTestTodo(in: context, title: "Test Title", completed: true)
        let testId = testTodo.id
        try context.save()
        
        // ACT
        let todoItem = try coreDataRepository.getTodo(id: testId)
        
        // ASSERT: Verify conversion
        XCTAssertEqual(todoItem.id, testId, "ID should match")
        XCTAssertEqual(todoItem.title, "Test Title", "Title should match")
        XCTAssertTrue(todoItem.completed, "Completed status should match")
        XCTAssertEqual(todoItem.userId, testTodo.userId, "UserId should match")
    }
    
    
    // MARK: - Query Logic Tests
    
    func testGetTodo_WithValidId_ReturnsTodo() throws {
        // ARRANGE
        let context = container.viewContext
        let testTodo = createTestTodo(in: context, title: "Find Me")
        let testId = testTodo.id
        try context.save()
        
        // ACT
        let todoItem = try coreDataRepository.getTodo(id: testId)
        
        // ASSERT
        XCTAssertEqual(todoItem.title, "Find Me", "Should find the correct todo")
    }
    
    func testGetTodo_WithInvalidId_ThrowsError() throws {
        // ACT & ASSERT
        XCTAssertThrowsError(try coreDataRepository.getTodo(id: 99999)) { error in
            let coreDataError = error as? TodoCoreDataError
            XCTAssertEqual(coreDataError, TodoCoreDataError.notFound(id: 99999), "Should throw notFound error")
        }
    }
    
    // MARK: - CRUD Operation Tests
    
    func testUpdateTodoTitle_UpdatesCorrectTodo() throws {
        // ARRANGE
        let context = container.viewContext
        let testTodo = createTestTodo(in: context, title: "Original")
        let testId = testTodo.id
        try context.save()
        
        // ACT
        try coreDataRepository.updateTodoTitle(id: testId, title: "Updated")
        
        // ASSERT: Verify in Core Data directly
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", testId)
        let todos = try context.fetch(request)
        let updatedTodo = try XCTUnwrap(todos.first)
        XCTAssertEqual(updatedTodo.title, "Updated", "Title should be updated")
    }
    
    func testToggleCompletion_TogglesCorrectTodo() throws {
        // ARRANGE
        let context = container.viewContext
        let testTodo = createTestTodo(in: context, completed: false)
        let testId = testTodo.id
        try context.save()
        
        // ACT
        try coreDataRepository.toggleCompletion(id: testId)
        
        // ASSERT
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", testId)
        let todos = try context.fetch(request)
        let toggledTodo = try XCTUnwrap(todos.first)
        XCTAssertTrue(toggledTodo.completed, "Completion should be toggled to true")
    }
    
    func testDeleteTodo_RemovesTodo() throws {
        // ARRANGE
        let context = container.viewContext
        let testTodo = createTestTodo(in: context)
        let testId = testTodo.id
        try context.save()
        
        // ACT
        try coreDataRepository.deleteTodo(id: testId)
        try coreDataRepository.save()
        
        // ASSERT
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", testId)
        let todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 0, "Todo should be deleted")
    }
    
    // MARK: - Batch Upsert Tests
    
    func testBatchUpsert_WithNewTodos_CreatesTodos() async throws {
        // ARRANGE
        let dtos = [
            TodoDTO(userId: Int(TodoConstants.userId), id: 1, title: "New Todo 1", completed: false),
            TodoDTO(userId: Int(TodoConstants.userId), id: 2, title: "New Todo 2", completed: true)
        ]
        
        // ACT
        try await coreDataRepository.batchUpsert(dtos)
        
        // ASSERT: Verify todos were created
        let context = container.viewContext
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", [1, 2])
        let todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 2, "Should create 2 new todos")
        
        let todo1 = todos.first { $0.id == 1 }
        XCTAssertEqual(todo1?.title, "New Todo 1", "First todo should have correct title")
        XCTAssertNil(todo1?.createdAt, "Network todos should not have createdAt")
    }
    
    func testBatchUpsert_WithExistingTodos_UpdatesTodos() async throws {
        // ARRANGE: Create existing todos
        let context = container.viewContext
        let existingTodo1 = createTestTodo(in: context, title: "Original 1")
        existingTodo1.id = 1
        existingTodo1.completed = false
        let existingTodo2 = createTestTodo(in: context, title: "Original 2")
        existingTodo2.id = 2
        existingTodo2.completed = false
        try context.save()
        
        // ACT: Upsert with updated data
        let dtos = [
            TodoDTO(userId: Int(TodoConstants.userId), id: 1, title: "Updated 1", completed: true),
            TodoDTO(userId: Int(TodoConstants.userId), id: 2, title: "Updated 2", completed: true)
        ]
        try await coreDataRepository.batchUpsert(dtos)
        
        // ASSERT: Verify todos were updated (not duplicated)
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", [1, 2])
        let todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 2, "Should still have 2 todos (not 4)")
        
        let updatedTodo1 = todos.first { $0.id == 1 }
        XCTAssertEqual(updatedTodo1?.title, "Updated 1", "First todo should be updated")
        XCTAssertTrue(updatedTodo1?.completed ?? false, "First todo should be completed")
    }
    
    func testBatchUpsert_WithMixedNewAndExisting_HandlesBoth() async throws {
        // ARRANGE: Create one existing todo
        let context = container.viewContext
        let existingTodo = createTestTodo(in: context, title: "Existing")
        existingTodo.id = 1
        try context.save()
        
        // ACT: Upsert with one existing and one new
        let dtos = [
            TodoDTO(userId: Int(TodoConstants.userId), id: 1, title: "Updated Existing", completed: true),
            TodoDTO(userId: Int(TodoConstants.userId), id: 2, title: "New Todo", completed: false)
        ]
        try await coreDataRepository.batchUpsert(dtos)
        
        // ASSERT
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", [1, 2])
        let todos = try context.fetch(request)
        XCTAssertEqual(todos.count, 2, "Should have 2 todos total")
        
        let updated = todos.first { $0.id == 1 }
        XCTAssertEqual(updated?.title, "Updated Existing", "Existing todo should be updated")
        
        let new = todos.first { $0.id == 2 }
        XCTAssertEqual(new?.title, "New Todo", "New todo should be created")
    }
    
    // MARK: - Error Handling Tests
    
    func testUpdateTodoTitle_WithInvalidId_ThrowsError() throws {
        // ACT & ASSERT
        XCTAssertThrowsError(try coreDataRepository.updateTodoTitle(id: 99999, title: "Test")) { error in
            let coreDataError = error as? TodoCoreDataError
            XCTAssertEqual(coreDataError, TodoCoreDataError.notFound(id: 99999), "Should throw notFound error")
        }
    }
    
    func testToggleCompletion_WithInvalidId_ThrowsError() throws {
        // ACT & ASSERT
        XCTAssertThrowsError(try coreDataRepository.toggleCompletion(id: 99999)) { error in
            let coreDataError = error as? TodoCoreDataError
            XCTAssertEqual(coreDataError, TodoCoreDataError.notFound(id: 99999), "Should throw notFound error")
        }
    }
    
    func testDeleteTodo_WithInvalidId_ThrowsError() throws {
        // ACT & ASSERT
        XCTAssertThrowsError(try coreDataRepository.deleteTodo(id: 99999)) { error in
            let coreDataError = error as? TodoCoreDataError
            XCTAssertEqual(coreDataError, TodoCoreDataError.notFound(id: 99999), "Should throw notFound error")
        }
    }
}

