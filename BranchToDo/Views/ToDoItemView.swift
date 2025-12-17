//
//  ToDoItem.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI

struct ToDoItemView: View {
    
    var todo: Todo
    var onToggleCompletion: () -> Void
    
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
            VStack(alignment: .leading, spacing: 2) {
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

