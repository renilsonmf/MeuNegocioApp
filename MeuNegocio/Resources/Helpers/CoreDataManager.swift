//
//  CoreDataManager.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 13/07/24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    var productList: [NSManagedObject] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MeuNegocioModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Erro ao carregar o Core Data Store: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
