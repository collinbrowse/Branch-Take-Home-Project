//
//  ContentView.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI
import CoreData

struct ListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.createdAt, ascending: false)],
        animation: .default)
    private var todos: FetchedResults<Todo>
    
    @StateObject private var viewModel: ListVM
    @FocusState private var isFocused: Bool

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ListVM(context: context))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(todos) { todo in
                    if todo == viewModel.currentTodo {
                        TextField("", text: $viewModel.newTitle)
                            .focused($isFocused)
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
                        offsets.map { todos[$0] }.forEach(viewContext.delete)
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.isEditing.toggle()
                            if viewModel.isEditing {
                                isFocused = true
                            }
                        }
                    } label: {
                        if viewModel.isEditing {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(uiColor: .systemGreen))
                        } else {
                            Image(systemName: "plus")
                        }
                    }
                    .accessibilityLabel(viewModel.isEditing ? "Add" : "Edit")
                }
            }
            .navigationTitle("Todos")
        }
        .task {
            await viewModel.fetchTodosFromAPI()
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
    ListView(context: PersistenceController.preview.container.viewContext)
}
