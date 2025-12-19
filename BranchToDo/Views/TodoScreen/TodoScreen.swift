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
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var allTodos: FetchedResults<Todo>
    
    @StateObject private var viewModel: TodoVM

    init(viewModel: TodoVM) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                
                if allTodos.isEmpty && !viewModel.isLoading {
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
    TodoScreen(viewModel: TodoVM(repo: CoreDataRepository(container: container)))
}

