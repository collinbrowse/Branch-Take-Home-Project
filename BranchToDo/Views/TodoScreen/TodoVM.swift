//
//  TodoVM.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//


import SwiftUI
import Combine
import CoreData

@MainActor
class TodoVM: ObservableObject {
    
    @Published var currentTodoId: NSManagedObjectID?
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
            // Update the todo title in Core Data as user types
            if let title = newTitle,
                let objectId = currentTodoId {
                updateTodoTitle(objectId: objectId, title: title)
            }
        }
    }
    
    private var repository: TodoRepositoryProtocol
    
    init(repo: TodoRepositoryProtocol) {
        self.repository = repo
    }

    // MARK: - CRUD Operations
    
    func addEmptyTodo() {
        do {
            let objectID = try repository.createEmptyTodo()
            currentTodoId = objectID
            newTitle = ""
        } catch {
            TodoErrorLogger.logMessage("Error creating empty todo: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Unable to create new todo"
                self.isLoading = false
            }
        }
    }
    
    func finishEditing() {
        if let objectId = currentTodoId {
            do {
                let todo = try repository.getTodo(objectId: objectId)
                // If it's a valid title (not an empty string)
                if let title = todo.title, !title.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Save the view context to persist the new todo
                    try repository.save()
                } else {
                    try repository.deleteTodo(objectId: objectId)
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
    
    func deleteTodo(objectId: NSManagedObjectID) {
        do {
            try repository.deleteTodo(objectId: objectId)
            try repository.save()
        } catch {
            TodoErrorLogger.logMessage("Error deleting the todo: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Error deleting your entry"
                self.isLoading = false
            }
        }
    }
    
    func toggleCompletion(objectId: NSManagedObjectID) {
        do {
            try repository.toggleCompletion(objectId: objectId)
            try repository.save()
        } catch {
            TodoErrorLogger.logMessage("Error updating the todo completion status: \(error.localizedDescription)")
            withAnimation(.easeInOut) {
                self.errorMessage = "Error updating your entry"
                self.isLoading = false
            }
        }
    }
    
    func updateTodoTitle(objectId: NSManagedObjectID, title: String) {
        // Valdiate the input first
        let sanitizedTitle = TitleSanitizer.sanitize(title)
        guard sanitizedTitle != "" else {
            errorMessage = "Please enter a valid input"
            return
        }
        
        // Save if valid
        do {
            try repository.updateTodoTitle(objectId: objectId, title: title)
        } catch {
            TodoErrorLogger.logMessage("Error updating todo title: \(error.localizedDescription)")
        }
    }
    
    /// Fetch a list of Demo Todos from the network
    func fetchDemoTodos() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                try await repository.fetchDemoTodosAndSave()
                isLoading = false
            } catch {
                TodoErrorLogger.logMessage("Error getting the todos: \(error.localizedDescription)")
                withAnimation(.easeInOut) {
                    self.errorMessage = "Unable to load examples from the network: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
