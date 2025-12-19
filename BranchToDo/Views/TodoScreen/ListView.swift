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
                    isCurrentTodo: todo.objectID == viewModel.currentTodoId,
                    onToggleCompletion: {
                        viewModel.toggleCompletion(objectId: todo.objectID)
                    }
                )
            }
            .onDelete { offsets in
                for index in offsets {
                    let todo = allTodos[index]
                    viewModel.deleteTodo(objectId: todo.objectID)
                }
            }
        }
        .scrollContentBackground(.hidden)
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
    let repo = CoreDataRepository(container: container)
    let vm = TodoVM(repo: repo)
    ListView(viewModel: vm)
        .environment(\.managedObjectContext, container.viewContext)
}

