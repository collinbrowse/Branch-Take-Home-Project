//
//  ToDoItem.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI

struct TodoItemView: View {
    
    @ObservedObject var todo: Todo
    @ObservedObject var viewModel: TodoVM
    var isCurrentTodo: Bool
    var onToggleCompletion: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            Button {
                onToggleCompletion()
            } label: {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.completed ? .green : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isEditing && isCurrentTodo)
            VStack(alignment: .leading, spacing: 2) {
                
                // Display Text Field if currently entering
                if isCurrentTodo {
                    TextField("", text: Binding(
                        get: { viewModel.newTitle ?? "" }, // Unwrap for display
                        set: { viewModel.newTitle = $0 }   // Wrap for storage
                    ))
                    .focused($isFocused)
                    .font(.headline)
                    .onSubmit {
                        viewModel.isEditing = false
                    }
                    .onAppear {
                        if viewModel.isEditing {
                            isFocused = true
                        }
                    }
                }
                // Else, Display the title as Text
                else {
                    Text(todo.title ?? "New Todo")
                        .font(.headline)
                        .strikethrough(todo.completed)
                    
                    if let createdAt = todo.createdAt {
                        Text("\(createdAt, formatter: itemFormatter)")
                            .font(.caption2)
                    }
                }
            }
        }
    }
}

