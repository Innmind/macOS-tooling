//
//  Persistence.swift
//  Innmind
//
//  Created by Baptouuuu on 14/11/2021.
//

import CoreData

struct Persistence {
    static let shared = Persistence()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Innmind")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print(error)
            }
        }
    }

    func save(completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        if !context.hasChanges {
            return
        }

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        context.delete(object)
        save(completion: completion)
    }
}
