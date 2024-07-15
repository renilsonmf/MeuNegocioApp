//
//  AddProcedureViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/08/22.
//

import UIKit
import CoreData

protocol AddProcedureViewModelProtocol {
    func createProcedure(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void)
    func createProcedureCoreData(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void)
    func closed()
}

class AddProcedureViewModel: AddProcedureViewModelProtocol {

    // MARK: - Properties
    private var coordinator: AddProcedureCoordinator?

    // MARK: - Init
    init(coordinator: AddProcedureCoordinator?) {
        self.coordinator = coordinator
    }

    // MARK: - Routes
    func closed() {
        coordinator?.closed()
    }

    // MARK: - Methods
    func createProcedure(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://54.86.122.10:3000/procedure") else {
            print("Error: cannot create URL")
            return
        }

        /// Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(procedure) else {
            print("Error: Trying to convert model to JSON data")
            return
        }

        /// Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false)
                return
            }
           
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                completion(false)
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        }.resume()
    }
    
    func createProcedureCoreData(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void) {
        let entity = NSEntityDescription.entity(forEntityName: "AddProduct", in: CoreDataManager.shared.managedObjectContext)!
        let objeto = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
        
        // Configurar os atributos do objeto
        objeto.setValue(UUID().uuidString, forKeyPath: "id")
        objeto.setValue(procedure.value, forKeyPath: "value")
        objeto.setValue(procedure.nameClient, forKeyPath: "nameClient")
        objeto.setValue(procedure.formPayment, forKeyPath: "formPayment")
        objeto.setValue(procedure.email, forKeyPath: "email")
        objeto.setValue(procedure.typeProcedure, forKeyPath: "typeProcedure")
        objeto.setValue(procedure.currentDate, forKeyPath: "currentDate")
        objeto.setValue(procedure.costs, forKeyPath: "costs")
        
        
        // Salvar o contexto
        do {
            try CoreDataManager.shared.managedObjectContext.save()
            completion(true)
        } catch let error as NSError {
            print("Erro ao adicionar Produto: \(error), \(error.userInfo)")
            completion(false)
        }
    }
}
