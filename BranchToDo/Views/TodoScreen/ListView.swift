//
//  ContentView.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI

struct ListView: View {
    
    var todos: [Todo]
    @ObservedObject var viewModel: TodoVM
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        List {
            ForEach(todos) { todo in
                if todo == viewModel.currentTodo {
                    TextField("", text: $viewModel.newTitle)
                        .focused(isFocused)
                        .font(.headline)
                        .onSubmit {
                            viewModel.isEditing = false
                        }
                } else {
                    ToDoItemView(todo: todo, onToggleCompletion: {
                        viewModel.toggleTodoCompletion(todo)
                    })
                }
            }
            .onDelete { offsets in
                withAnimation {
                    let itemsToDelete: [Todo] = offsets.map { self.todos[$0] }
                    viewModel.deleteTodos(itemsToDelete)
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
//    ListView(todos: [], viewModel: TodoVM(context: PersistenceController.preview.container.viewContext), isFocused: FocusState())
}

