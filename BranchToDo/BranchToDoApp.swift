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
                .onAppear {
                    Task {
                        do {
                            let todos = try await TodoAPIService.fetchTodos()
                            for todo in todos {
                                print(todo)
                            }
                        } catch {
                            print("Error getting the todos: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
