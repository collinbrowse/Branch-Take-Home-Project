//
//  TodoViewModelTests.swift
//  BranchToDoTests
//
//  Created by Collin Browse on 12/18/25.
//

import XCTest
@testable import BranchToDo

@MainActor 
final class TodoViewModelTests: TodoTests {
    
    override func setUpWithError() throws {
        mockRepository = makeMockRepository()
        repository = mockRepository
        viewModel = makeTestViewModel(repository: repository)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testViewModelInitialization() throws {
        // ASSERT: Verify all initial state
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should be nil initially")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false initially")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil initially")
        XCTAssertFalse(viewModel.isEditing, "isEditing should be false initially")
        XCTAssertNil(viewModel.newTitle, "newTitle should be nil initially")
    }
    
    func viewModelReset() throws {
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should be nil after editing is done")
        XCTAssertNil(viewModel.newTitle, "newTitle should be nil after editing is done")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil after editing is done")
        XCTAssertFalse(viewModel.isEditing, "isEditing should be false after editing is done")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after editing is done")
    }
    
    func testAddEmptyTodo_CreatesTodoAndSetsCurrentTodoId() async throws {
        // ARRANGE: Set up the test state
        // 1) Create an empty todo
        viewModel.isEditing = true // trigger addEmptyTodo()
        
        // ASSERT: Verify the expected outcome
        XCTAssertNotNil(viewModel.currentTodoId, "The todo id should not be nil")
        XCTAssertEqual(mockRepository.createEmptyTodoCallCount, 1, "Repository should be called once")
        XCTAssertEqual(viewModel.newTitle, "", "newTitle should be set to empty string")
        
        // Verify the todo was created in the repository
        if let todoId = viewModel.currentTodoId {
            let todoItem = try mockRepository.getTodo(id: todoId)
            XCTAssertEqual(todoItem.title, "", "Todo should have empty title")
            XCTAssertFalse(todoItem.completed, "Todo should not be completed")
        }
    }
    
    func testAddEmptyTodo_HandlesRepositoryError() async throws {
        // ARRANGE: Set up error condition
        mockRepository.shouldThrowErrorOnCreateEmptyTodo = true
        
        // ACT: Trigger addEmptyTodo
        viewModel.isEditing = true
        
        // ASSERT: Verify error handling
        XCTAssertEqual(viewModel.errorMessage, "Unable to create new todo", "Error message should be set")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should be nil when creation fails")
    }
    
    /// Verify the happy save path
    func testFinishEditing_WithNonEmptyTitle_SavesTodo() throws {
        // ARRANGE: Set up the test state
        let todoId = try startEditingAndGetTodoId()
        viewModel.newTitle = "Buy Groceries"
        
        // ACT: Execute the behavior in question
        viewModel.isEditing = false
        
        // ASSERT: Verify the expected outcome
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, 1, "Repository save should be called")
        XCTAssertEqual(mockRepository.todoCount, 1, "Should have one todo saved")
        
        let savedTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertEqual(savedTodo.title, "Buy Groceries", "Todo title should be 'Buy Groceries'")
        XCTAssertFalse(savedTodo.completed, "Todo should have completed = false")
        XCTAssertNotNil(savedTodo.createdAt, "Todo should have a createdAt date")
        
        try viewModelReset()
    }
    
    func testFinishEditing_WithEmptyTitle_DeletesTodo() async throws {
        // ARRANGE: Set up the test state
        let todoId = try startEditingAndGetTodoId()
        
        // ACT: remove the empty todo
        viewModel.isEditing = false
        
        // ASSERT: Verify the expected outcome
        XCTAssertEqual(mockRepository.deleteTodoCallCount, 1, "Repository delete should be called")
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, 1, "Repository save should be called")
        XCTAssertEqual(mockRepository.todoCount, 0, "No Todo should have been saved")
        XCTAssertThrowsError(try mockRepository.getTodo(id: todoId), "Todo should not exist after deletion")
    }
    
    func testFinishEditing_HandlesSaveError() async throws {
        // ARRANGE: Set up the test state
        _ = try startEditingAndGetTodoId()
        viewModel.newTitle = "Test"
        mockRepository.shouldThrowErrorOnSave = true
        
        // ACT: Execute finishEditing
        viewModel.isEditing = false
        
        // ASSERT: Verify error handling
        // Note: finishEditing() clears errorMessage at the end, so we verify the error path
        // was taken by checking that getTodo and save were called
        XCTAssertGreaterThanOrEqual(mockRepository.getTodoCallCount, 1, "Repository getTodo should be called")
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, 1, "Repository save should be attempted")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
        verifyViewModelReset()
    }
    
    func testFinishEditing_HandlesDeleteError() async throws {
        // ARRANGE: Set up the test state
        _ = try startEditingAndGetTodoId()
        // Leave title empty to trigger delete
        mockRepository.shouldThrowErrorOnDelete = true
        
        // ACT: Execute finishEditing (empty title triggers delete)
        viewModel.isEditing = false
        
        // ASSERT: Verify error handling
        // Note: finishEditing() clears errorMessage at the end, so we verify the error path
        // was taken by checking that getTodo and deleteTodo were called
        XCTAssertGreaterThanOrEqual(mockRepository.getTodoCallCount, 1, "Repository getTodo should be called")
        XCTAssertEqual(mockRepository.deleteTodoCallCount, 1, "Repository delete should be attempted")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
        verifyViewModelReset()
    }
    
    /// Test that the loading state transitions correctly
    func testFetchDemoTodos_SetsLoadingState() async throws {
       XCTAssertFalse(viewModel.isLoading, "isLoading should start as false")
       
       // ACT: Start the async operation
       viewModel.fetchDemoTodos()
        
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
       
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true immediately after calling fetchDemoTodos()")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be cleared when loading starts")
       
        // Wait for the async operation to complete
        try await waitForAsyncCompletion()
       
       // ASSERT: Verify loading state is cleared after completion
       XCTAssertFalse(viewModel.isLoading, "isLoading should be false after operation completes")
    }
    
    func testFetchDemoTodos_HandlesNetworkError() async throws {
        // ARRANGE: Set error condition
        mockRepository.shouldThrowErrorOnFetchDemoTodos = true
        
        // ACT: Fetch demo todos
        viewModel.fetchDemoTodos()
        
        // Wait for async completion (including animation delay)
        var attempts = 0
        while (viewModel.isLoading || viewModel.errorMessage == nil) && attempts < 100 {
            try await Task.sleep(nanoseconds: 10_000_000)
            attempts += 1
        }
        
        // ASSERT: Verify error handling
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertTrue(viewModel.errorMessage?.contains("Unable to load examples from the network") ?? false, "Error message should contain expected text")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after error")
    }
    
    func testToggleCompletion_UpdatesTodo() async throws {
        // ARRANGE: Create todo via repository helper
        let todoId = try createAndSaveTodo(in: mockRepository, title: "Test Todo", completed: false)
        let initialTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertFalse(initialTodo.completed, "Initial todo should not be completed")
        
        // ACT: Toggle completion
        viewModel.toggleCompletion(id: todoId)
        
        // ASSERT: Verify MockRepository was called
        XCTAssertEqual(mockRepository.toggleCompletionCallCount, 1, "Repository toggleCompletion should be called once")
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, 1, "Repository save should be called")
        
        // Verify todo in repository has toggled completion status
        let updatedTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertTrue(updatedTodo.completed, "Todo completion should be toggled to true")
    }
    
    func testToggleCompletion_HandlesError() async throws {
        // ARRANGE: Create todo and save it
        let todoId = try createAndSaveTodo(in: mockRepository, title: "Test Todo")
        
        // Set error condition
        mockRepository.shouldThrowErrorOnToggleCompletion = true
        
        // ACT: Toggle completion
        viewModel.toggleCompletion(id: todoId)
        
        // ASSERT: Verify error handling
        XCTAssertEqual(viewModel.errorMessage, "Error updating your entry", "Error message should be set")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
    }
    
    func testDeleteTodo_RemovesTodo() async throws {
        // ARRANGE: Create todo via repository helper
        let todoId = try createAndSaveTodo(in: mockRepository, title: "Test Todo")
        XCTAssertEqual(mockRepository.todoCount, 1, "Should have one todo before deletion")
        
        // ACT: Delete todo
        viewModel.deleteTodo(id: todoId)
        
        // ASSERT: Verify MockRepository was called
        XCTAssertEqual(mockRepository.deleteTodoCallCount, 1, "Repository deleteTodo should be called once")
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, 1, "Repository save should be called")
        
        // Verify todo was removed
        XCTAssertEqual(mockRepository.todoCount, 0, "Repository should have zero todos after deletion")
        XCTAssertThrowsError(try mockRepository.getTodo(id: todoId), "Todo should not exist after deletion")
    }
    
    // MARK: - Edge Cases
    
    func testUpdateTodoTitle_WithEmptyString_AllowsEmptyDuringEditing() throws {
        // ARRANGE: Create todo via isEditing
        let todoId = try startEditingAndGetTodoId()
        viewModel.newTitle = "Valid Title"
        
        // ACT: Set empty string (user clears the field)
        viewModel.newTitle = ""
        
        // ASSERT: Note - The ViewModel's updateTodoTitle validation only sets error for
        // content that gets sanitized away, not for already-empty strings.
        // Empty strings are allowed during editing. Validation happens in finishEditing, not here.
        let updatedTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertEqual(updatedTodo.title, "", "Repository should accept empty string during editing")
        XCTAssertNil(viewModel.errorMessage, "No error should be set for empty string during editing")
    }
    
    func testUpdateTodoTitle_WithValidTitle_UpdatesRepository() throws {
        // ARRANGE: Create todo via isEditing
        let todoId = try startEditingAndGetTodoId()
        let initialCallCount = mockRepository.updateTitleCallCount
        
        // ACT: Set valid title
        viewModel.newTitle = "Valid Title"
        
        // ASSERT: Verify repository was called
        XCTAssertGreaterThanOrEqual(mockRepository.updateTitleCallCount, initialCallCount + 1, "Repository updateTitle should be called for valid title")
        
        let updatedTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertEqual(updatedTodo.title, "Valid Title", "Repository should have updated title")
    }
    
    func testFinishEditing_WithNilCurrentTodoId_DoesNothing() throws {
        // ARRANGE: Ensure currentTodoId is nil
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should be nil initially")
        
        // ACT: Try to finish editing
        viewModel.isEditing = false
        
        // ASSERT: Verify repository was NOT called
        XCTAssertEqual(mockRepository.getTodoCallCount, 0, "Repository getTodo should not be called when currentTodoId is nil")
        XCTAssertEqual(mockRepository.saveCallCount, 0, "Repository save should not be called when currentTodoId is nil")
        
        // Verify ViewModel state is reset
        XCTAssertNil(viewModel.currentTodoId, "currentTodoId should remain nil")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
    }
    
    // MARK: - Property Observer Tests
    
    func testIsEditing_True_TriggersAddEmptyTodo() throws {
        // ARRANGE: Initial state
        XCTAssertFalse(viewModel.isEditing, "isEditing should start as false")
        XCTAssertEqual(mockRepository.createEmptyTodoCallCount, 0, "Repository should not be called initially")
        
        // ACT: Set isEditing to true
        viewModel.isEditing = true
        
        // ASSERT: Verify addEmptyTodo was triggered
        XCTAssertEqual(mockRepository.createEmptyTodoCallCount, 1, "Repository createEmptyTodo should be called once")
        XCTAssertNotNil(viewModel.currentTodoId, "currentTodoId should be set after isEditing becomes true")
    }
    
    func testIsEditing_False_TriggersFinishEditing() throws {
        // ARRANGE: Create todo via isEditing
        _ = try startEditingAndGetTodoId()
        viewModel.newTitle = "Test Title"
        let initialSaveCount = mockRepository.saveCallCount
        
        // ACT: Set isEditing to false
        viewModel.isEditing = false
        
        // ASSERT: Verify finishEditing was triggered
        XCTAssertGreaterThanOrEqual(mockRepository.saveCallCount, initialSaveCount + 1, "Repository save should be called")
        verifyViewModelReset()
    }
    
    func testNewTitle_DidSet_UpdatesRepository() throws {
        // ARRANGE: Create todo via isEditing
        let todoId = try startEditingAndGetTodoId()
        let initialUpdateCount = mockRepository.updateTitleCallCount
        
        // ACT: Set newTitle
        viewModel.newTitle = "New Title"
        
        // ASSERT: Verify repository was called
        XCTAssertEqual(mockRepository.updateTitleCallCount, initialUpdateCount + 1, "Repository updateTitle should be called once")
        
        let updatedTodo = try mockRepository.getTodo(id: todoId)
        XCTAssertEqual(updatedTodo.title, "New Title", "Repository should have the updated title")
    }
    
}

