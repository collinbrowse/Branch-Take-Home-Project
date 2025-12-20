//
//  EmptyStateView.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/18/25.
//

import SwiftUI
import CoreData

struct EmptyStateView: View {
    
    @ObservedObject var viewModel: TodoVM
    
    var body: some View {
        VStack(spacing: 25) {
            Text("You don't have any todo's yet")
                .font(.headline)
            Text("Start by tapping the + button in the top right")
                .font(.headline)
            Text("OR")
                .font(.headline)
            Button {
                // One time call to populate core data with demo todos
                viewModel.fetchDemoTodos()
            } label: {
                Text("Load Demo Todo Items")
                    .foregroundStyle(.primary)
            }
            .buttonStyle(LiquidGlassButtonStyle(isLoading: viewModel.isLoading))
            .disabled(viewModel.isLoading)
            
            if let errorString = viewModel.errorMessage {
                ErrorView(message: errorString)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
            }
        }
    }
}

#Preview {
    let container = PersistenceController.preview.container
    let repo = CoreDataRepository(container: container, userId: ToDoConstants.userId)
    let vm = TodoVM(repo: repo)
    EmptyStateView(viewModel: vm)
}
