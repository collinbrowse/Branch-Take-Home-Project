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
    
    @FetchRequest var todos: FetchedResults<Todo>
    
    @StateObject private var viewModel: TodoVM

    init(viewModel: TodoVM) {
        _viewModel = StateObject(wrappedValue: viewModel)
        
        // Just check existence of any todo
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = []
        request.fetchLimit = 1
        request.includesPropertyValues = false
        _todos = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    // Branch's RGB from their website
                    colors: [Color(red: 0.137254902, green: 0.5137254902, blue: 0.2392156863), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if todos.isEmpty {
                    EmptyStateView(viewModel: viewModel)
                } else {
                    ListView(viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.isEditing.toggle()
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
    let container = PersistenceController.preview.container
    TodoScreen(viewModel: TodoVM(repo: CoreDataRepository(container: container, userId: TodoConstants.userId)))
}

