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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
