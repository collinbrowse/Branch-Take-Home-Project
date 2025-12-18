//
//  TodoScreen.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//

import SwiftUI
import CoreData

struct TodoScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: TodoRepository.getAllTodos())
    private var todos: FetchedResults<Todo>
    
    @StateObject private var viewModel: TodoVM
    @FocusState private var isFocused: Bool

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TodoVM(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.4, green: 0.6, blue: 1.0), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if todos.isEmpty {
                    EmptyStateView(viewModel: viewModel)
                } else {
                    ListView(todos: Array(todos), viewModel: viewModel, isFocused: $isFocused)
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
    }
}

#Preview {
    TodoScreen(context: PersistenceController.preview.container.viewContext)
}

