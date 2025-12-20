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
        repository = CoreDataRepository(container: container, userId: TodoConstants.userId) // replace userId with auth solution
        configureNavBar()
    }
    
    var body: some Scene {
        WindowGroup {
            TodoScreen(
                viewModel: TodoVM(repo: repository)
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func configureNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
