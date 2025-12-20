//
//  TodoTests.swift
//  BranchToDoTests
//
//  Created by Collin Browse on 12/20/25.
//

import XCTest
@testable import BranchToDo
import CoreData

@MainActor
class TodoTests: XCTestCase {

    var controller: PersistenceController!
    var container: NSPersistentContainer!
    var repository: TodoRepositoryProtocol!
    var viewModel: TodoVM!
    var mockRepository: MockRepository!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Setup Core Data container for tests that need real persistence
    func setupTestContainer() throws {
        container = makeTestContainer()
    }
    
    /// Setup Core Data repository for tests that need real persistence
    func setupTestRepository() throws {
        guard let container = container else {
            throw NSError(domain: "TodoTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container must be set up before repository"])
        }
        repository = makeTestRepository(container: container)
    }

    func makeTestContainer() -> NSPersistentContainer {
        return PersistenceController(inMemory: true).container
    }
    
    func makeTestRepository(container: NSPersistentContainer) -> CoreDataRepository {
        return CoreDataRepository(container: container, userId: TodoConstants.userId)
    }
    
    func makeMockRepository() -> MockRepository {
        return MockRepository(userId: TodoConstants.userId)
    }
    
    @MainActor
    func makeTestViewModel(repository: TodoRepositoryProtocol) -> TodoVM {
        return TodoVM(repo: repository)
    }
    
    /// Helper to create and save a todo via MockRepository for test setup
    @MainActor
    func createAndSaveTodo(in repository: MockRepository, title: String = "Test Todo", completed: Bool = false) throws -> Int32 {
        let todoItem = try repository.createEmptyTodo()
        try repository.updateTodoTitle(id: todoItem.id, title: title)
        if completed {
            try repository.toggleCompletion(id: todoItem.id)
        }
        try repository.save()
        return todoItem.id
    }
    
    /// Helper to start editing mode and create an empty todo via ViewModel
    /// Returns the created todo ID
    @MainActor
    func startEditingAndGetTodoId() throws -> Int32 {
        viewModel.isEditing = true
        return try XCTUnwrap(viewModel.currentTodoId, "Todo ID should be set after creating empty todo")
    }
    
    /// Helper to wait for async operation to complete (checks isLoading)
    func waitForAsyncCompletion(maxAttempts: Int = 100, delayNanoseconds: UInt64 = 10_000_000) async throws {
        var attempts = 0
        while viewModel.isLoading && attempts < maxAttempts {
            try await Task.sleep(nanoseconds: delayNanoseconds)
            attempts += 1
        }
    }
    
    /// Helper to verify ViewModel state is reset after editing
    func verifyViewModelReset() {
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should be reset")
        XCTAssertNil(viewModel.newTitle, "newTitle should be reset")
        XCTAssertFalse(viewModel.isEditing, "isEditing should be false")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
    }
    
    // MARK: - Core Data Test Helpers
    
    /// Create a test Todo in the given context
    func createTestTodo(
        in context: NSManagedObjectContext,
        title: String = "Test Todo",
        completed: Bool = false,
        createdAt: Date? = Date.now
    ) -> Todo {
        let todo = Todo(context: context)
        todo.id = Int32.randomInt32Id()
        todo.userId = Int32.randomInt32Id()
        todo.title = title
        todo.completed = completed
        todo.createdAt = createdAt
        return todo
    }
    
    /// Create multiple test Todos in the given context
    func createTestTodos(
        in context: NSManagedObjectContext,
        count: Int
    ) -> [Todo] {
        var todos: [Todo] = []
        for i in 0..<count {
            let todo = createTestTodo(
                in: context,
                title: "Test Todo \(i)",
                createdAt: Date.now.addingTimeInterval(TimeInterval(-i * 60))
            )
            todos.append(todo)
        }
        return todos
    }

}
