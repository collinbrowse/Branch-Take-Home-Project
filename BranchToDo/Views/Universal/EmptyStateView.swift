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
            Group {
                Text("You don't have anything on your list yet")
                Text("Add a new item")
                Text("OR")
            }
            .font(.headline)
            .foregroundStyle(.black)
            
            Button {
                // One time call to populate core data with demo todos
                viewModel.fetchDemoTodos()
            } label: {
                ZStack {
                    Text("Load Demo Todo Items")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .opacity(viewModel.isLoading ? 0 : 1)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    }
                }
            }
            .buttonStyle(.glass)
            .disabled(viewModel.isLoading)
            .animation(.default, value: viewModel.isLoading)
            
            if let errorString = viewModel.errorMessage {
                ErrorView(message: errorString)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
            }
        }
            .multilineTextAlignment(.center)
    }
}

#Preview {
    let container = PersistenceController.preview.container
    let repo = CoreDataRepository(container: container, userId: TodoConstants.userId)
    let vm = TodoVM(repo: repo)
    EmptyStateView(viewModel: vm)
}
