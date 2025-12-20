//
//  ListView.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI
import CoreData

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Todo.createdAt, ascending: false)
        ],
        predicate: NSPredicate(format: "createdAt != nil"),
        animation: .default
    ) private var todosWithDates: FetchedResults<Todo>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "createdAt == nil"),
        animation: .default
    ) private var todosWithoutDates: FetchedResults<Todo>
    
    @ObservedObject var viewModel: TodoVM
    
    private var allTodos: [Todo] {
        Array(todosWithDates) + Array(todosWithoutDates)
    }
    
    var body: some View {
        List {
            ForEach(allTodos) { todo in
                TodoItemView(
                    todo: todo,
                    viewModel: viewModel,
                    isCurrentTodo: todo.id == viewModel.currentTodoId,
                    onToggleCompletion: {
                        viewModel.toggleCompletion(id: todo.id)
                    }
                )
            }
            .onDelete { offsets in
                for index in offsets {
                    let todo = allTodos[index]
                    viewModel.deleteTodo(id: todo.id)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top, spacing: 10) {
            // Add to error view to safe area so SwiftUI doesn't hide navigation title when displaying
            if let errorString = viewModel.errorMessage {
                ErrorView(message: errorString)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
                    .background(Color.clear) // Ensure it doesn't interfere with navigation bar
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    let container = PersistenceController.preview.container
    let repo = CoreDataRepository(container: container, userId: TodoConstants.userId)
    let vm = TodoVM(repo: repo)
    ListView(viewModel: vm)
        .environment(\.managedObjectContext, container.viewContext)
}

