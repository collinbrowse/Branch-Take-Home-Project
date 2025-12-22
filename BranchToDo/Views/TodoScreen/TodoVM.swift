//
//  TodoVM.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//


import SwiftUI
import Combine

@MainActor
class TodoVM: ObservableObject {
    
    @Published var currentTodoId: Int32?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEditing: Bool = false {
        didSet {
            if isEditing {
                addEmptyTodo()
            }
            else {
                finishEditing()
            }
        }
    }
    @Published var newTitle: String? {
        didSet {
            // Update the todo title as user types
            if let title = newTitle,
                let todoId = currentTodoId {
                updateTodoTitle(id: todoId, title: title)
            }
        }
    }
    
    private var repository: TodoRepositoryProtocol
    private var fetchTask: Task<Void, Never>?
    
    init(repo: TodoRepositoryProtocol) {
        self.repository = repo
    }
    
    deinit {
        fetchTask?.cancel()
    }

    // MARK: - CRUD Operations
    
    /// Add a todo item, but don't give it a title yet
    /// Do not save the empty todo to the data store
    func addEmptyTodo() {
        do {
            let todoItem = try repository.createEmptyTodo()
            currentTodoId = todoItem.id
            newTitle = todoItem.title
        } catch {
            TodoErrorLogger.logMessage("Error creating empty todo: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Unable to create new todo"
                self.isLoading = false
            }
        }
    }
    
    /// Save the updated to-do to the data store
    /// If the to-do is empty, remove it
    /// Reset the view state
    func finishEditing() {
        if let todoId = currentTodoId {
            do {
                let todoItem = try repository.getTodo(id: todoId)
                // If it's a valid title (not an empty string)
                if !todoItem.title.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Save to persist the new todo
                    try repository.save()
                } else {
                    try repository.deleteTodo(id: todoId)
                    try repository.save()
                }
            } catch {
                TodoErrorLogger.logMessage("Error finishing editing: \(error.localizedDescription)")
                withAnimation(.easeInOut) {
                    self.errorMessage = "Unable to finish editing"
                    self.isLoading = false
                }
            }
        }
        isLoading = false
        currentTodoId = nil
        newTitle = nil
        errorMessage = nil
    }
    
    /// Remove the to-do item from the data store
    /// - Parameters:
    ///     - id: the id of the to-do item
    func deleteTodo(id: Int32) {
        do {
            try repository.deleteTodo(id: id)
            try repository.save()
        } catch {
            TodoErrorLogger.logMessage("Error deleting the todo: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Error deleting your entry"
                self.isLoading = false
            }
        }
    }
    
    /// Toggle the completion status as save to the data store
    /// - Parameters:
    ///     - id: the id of the to-do item
    func toggleCompletion(id: Int32) {
        do {
            try repository.toggleCompletion(id: id)
            try repository.save()
        } catch {
            TodoErrorLogger.logMessage("Error updating the to-do completion status: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Error updating your entry"
                self.isLoading = false
            }
        }
    }
    
    /// Update the todo title
    /// Do not save to the data store
    /// - Parameters:
    ///     - id: the id of the to-do item
    func updateTodoTitle(id: Int32, title: String) {
        // Validate the input first
        let sanitizedTitle = TitleSanitizer.sanitize(title)
        if sanitizedTitle == "" && title != "" {
            errorMessage = "Please enter a valid input"
            return
        }
        
        // Update if valid
        do {
            try repository.updateTodoTitle(id: id, title: title)
        } catch {
            TodoErrorLogger.logMessage("Error updating to-do title: \(error.localizedDescription)")
        }
    }
    
    /// Fetch a list of Demo Todos from the network
    func fetchDemoTodos() {
        fetchTask?.cancel()
        fetchTask = Task {
            isLoading = true
            errorMessage = nil
            do {
                try await repository.fetchDemoTodosAndSave()
                isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                TodoErrorLogger.logMessage("Error getting the to-dos: \(error.localizedDescription)")
                withAnimation(.easeInOut) {
                    self.errorMessage = "Unable to load examples from the network: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
