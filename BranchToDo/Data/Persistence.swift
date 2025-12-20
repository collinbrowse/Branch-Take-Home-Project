//
//  Persistence.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    /// PersistanceController for Xcode Previews
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newTodo = Todo(context: viewContext)
            newTodo.completed = false
            newTodo.createdAt = Date.now
            newTodo.id = Int32.randomInt32Id()
            newTodo.title = ""
            newTodo.userId = Int32.randomInt32Id()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            TodoErrorLogger.logError(nsError)
        }
        return result
    }()

    let container: NSPersistentContainer
    // Add a shared model to prevent conflicts
        private static let sharedModel: NSManagedObjectModel = {
            let modelURL = Bundle.main.url(forResource: "BranchToDo", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BranchToDo", managedObjectModel: Self.sharedModel)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            // For in-memory stores, load synchronously
            let semaphore = DispatchSemaphore(value: 0)
            var loadError: Error?
            container.loadPersistentStores { (storeDescription, error) in
                loadError = error
                semaphore.signal()
            }
            semaphore.wait()
            if let error = loadError as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        } else {
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
