//
//  ProcedureDetailService.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/01/23.
//

import Foundation
import CoreData

protocol ProcedureDetailServiceProtocol {
    func deleteProcedure(_ procedure: String, completion: @escaping (String) -> Void)
    func updateProcedure(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void)
    
    func deleteProcedureCoreData(_ procedure: String, completion: @escaping (String) -> Void)
    func updateProcedureCoreData(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void)
}

class ProcedureDetailService: ProcedureDetailServiceProtocol {

    /// Delete procedure
    func deleteProcedure(_ procedure: String, completion: @escaping (String) -> Void) {
        
        let deleteProcedureById = MNUserDefaults.getRemoteConfig()?.deleteProcedureById ?? "http://54.86.122.10:3000/procedure/"
        
        guard let url = URL(string: "\(deleteProcedureById)\(procedure)") else {
            print("Error: cannot create URL")
            return
        }
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlReq) { data, response, error in
            completion(error?.localizedDescription ?? "Deletado com sucesso!")
        }.resume()
    }
    
    func updateProcedure(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void) {
        
        let updateModel = ProceduresToUpdateModel(nameClient: procedure.nameClient,
                                                  typeProcedure: procedure.typeProcedure,
                                                  formPayment: procedure.formPayment.rawValue,
                                                  value: procedure.value,
                                                  costs: procedure.costs.orEmpty)
        
        
        let updateProcedureById = MNUserDefaults.getRemoteConfig()?.updateProcedureById ?? "http://54.86.122.10:3000/procedure/"
        
        guard let url = URL(string: "\(updateProcedureById)\(procedure._id)") else {
            print("Error: cannot create URL")
            return
        }

        /// Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(updateModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        /// Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else { return }

            guard error == nil else {
                DispatchQueue.main.async {
                    completion(UpdatedProceduresModel(), false)
                }
                return
            }
                    
            do {
                let model = try JSONDecoder().decode(UpdatedProceduresModel.self, from: data)
                DispatchQueue.main.async {
                    completion(model, true)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(UpdatedProceduresModel(), false)
                }
            }


        }.resume()
    }
}

// MARK: Metodos que remove o procedimento do CoreData
extension ProcedureDetailService {
    func deleteProcedureCoreData(_ procedure: String, completion: @escaping (String) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AddProduct")
        fetchRequest.predicate = NSPredicate(format: "id == %@", procedure)

        let context = CoreDataManager.shared.managedObjectContext
        
        do {
            let objects = try context.fetch(fetchRequest)
            
            for object in objects {
                guard let managedObject = object as? NSManagedObject else {
                    completion("Ocorreu um erro ao tentar deletar o procedimento!")
                    continue
                }
                
                context.delete(managedObject)
            }
            
            try context.save()
            completion("Deletado com sucesso!")
        } catch {
            completion("Ocorreu um erro ao tentar deletar o procedimento!")
        }
    }
    
    func updateProcedureCoreData(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AddProduct")
        fetchRequest.predicate = NSPredicate(format: "id == %@", procedure._id)
        
        let context = CoreDataManager.shared.managedObjectContext
        
        do {
            let objects = try context.fetch(fetchRequest)
            
            guard let object = objects.first as? NSManagedObject else {
                completion(UpdatedProceduresModel(), false)
                return
            }
            
            object.setValue(procedure.nameClient, forKey: "nameClient")
            object.setValue(procedure.typeProcedure, forKey: "typeProcedure")
            object.setValue(procedure.formPayment.rawValue, forKey: "formPayment")
            object.setValue(procedure.value, forKey: "value")
            object.setValue(procedure.costs.orEmpty, forKey: "costs")
            
            try context.save()
            
            let updatedModel = UpdatedProceduresModel(nameClient: procedure.nameClient,
                                                      typeProcedure: procedure.typeProcedure,
                                                      formPayment: procedure.formPayment.rawValue,
                                                      value: procedure.value,
                                                      costs: procedure.costs.orEmpty)
            completion(updatedModel, true)
        } catch {
            completion(UpdatedProceduresModel(), false)
        }
    }
}
