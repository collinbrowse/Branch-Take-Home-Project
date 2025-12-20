//
//  BranchToDoApp.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import SwiftUI
import CoreData

@main
struct BranchToDoApp: App {
    
    let persistenceController = PersistenceController.shared
    let container: NSPersistentContainer
    let repository: TodoRepositoryProtocol
    
    init() {
        container = PersistenceController.shared.container
        repository = CoreDataRepository(container: container, userId: ToDoConstants.userId) // replace userId with auth solution
    }
    
    var body: some Scene {
        WindowGroup {
            TodoScreen(
                viewModel: TodoVM(repo: repository)
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
