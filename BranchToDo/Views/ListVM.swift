//
//  TodoListVM.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI
import Combine
import CoreData

@MainActor
class ListVM: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEditing: Bool = false {
        didSet {
            // If we are now editing, add empty todo
            if isEditing {
                addEmptyTodo()
            }
            // If we are done editing, remove editing details
            else {
                if currentTodo?.title != "" {
                    saveViewContext()
                } else {
                    deleteCurrentTodo()
                }
                currentTodo = nil
            }
        }
    }
    @Published var newTitle: String = "" {
        didSet {
            if newTitle != "" {
                updateCurrentTodo()
            }
        }
    }
    private var viewContext: NSManagedObjectContext
    @Published var currentTodo: Todo?
    //    private var todoRepository: TodoRepositoryProtocol
    //    private var apiService: TodoAPIService
    
    init(context: NSManagedObjectContext ) {
        self.viewContext = context
    }

    // MARK: - CRUD Operations
    
    func addEmptyTodo() {
        let newTodo = Todo(context: viewContext)
        newTodo.completed = false
        newTodo.createdAt = Date.now
        newTodo.id = generateInt32ID()
        newTodo.title = ""
        newTodo.userId = generateInt32ID()
        currentTodo = newTodo
    }
    
    
    func updateCurrentTodo() {
        currentTodo?.title = newTitle
        saveViewContext()
    }
    
    /// Save user-added Todo to Core Data
    func addTodo(title: String) {
        withAnimation {
            let newTodo = Todo(context: viewContext)
            newTodo.completed = false
            newTodo.createdAt = Date.now
            newTodo.id = generateInt32ID()
            newTodo.title = title
            newTodo.userId = generateInt32ID()
        }
    }
    
    /// Save Todo from API to Core Data
    func addTodo(_ todo: TodoDTO) {
        let newTodo = Todo(context: viewContext)
        newTodo.completed = todo.completed
        newTodo.createdAt = todo.createdAt
        newTodo.id = Int32(todo.id)
        newTodo.title = todo.title
        newTodo.userId = Int32(todo.userId)
    }
    
    @MainActor
    func saveViewContext() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteCurrentTodo() {
        if let todo = currentTodo {
            viewContext.delete(todo)
            saveViewContext()
        }
    }
    
    func deleteTodos(_ items: [Todo]) {
        items.forEach(viewContext.delete)
        saveViewContext()
    }
    
    func toggleTodoCompletion(_ todo: Todo) {
        todo.completed.toggle()
        saveViewContext()
    }
    
    
    func fetchTodosFromAPI() async {
        do {
            let todos = try await TodoAPIService.fetchTodos()
            
            for todo in todos {
                addTodo(todo)
            }
            
            saveViewContext()
        } catch {
            TodoErrorLogger.logMessage("Error getting the todos: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    func generateInt32ID() -> Int32 {
        Int32.random(in: Int32.min...Int32.max)
    }
}
