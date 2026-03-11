//
//  ProcedureDetailService.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/01/23.
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth

protocol ProcedureDetailServiceProtocol {
    func deleteProcedureFirestore(_ procedure: String, completion: @escaping (String) -> Void)
    func updateProcedureCoreData(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void)
}

class ProcedureDetailService: ProcedureDetailServiceProtocol {
    
    private let firestore = Firestore.firestore()
    
    func deleteProcedureFirestore(_ procedureId: String, completion: @escaping (String) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion("Usuário não autenticado")
            return
        }
                
        firestore.collection("users")
            .document(uid)
            .collection("procedures")
            .document(procedureId)
            .delete { error in
                
                if let error = error {
                    print("Erro ao deletar:", error)
                    completion("Ocorreu um erro ao tentar deletar o procedimento!")
                } else {
                    completion("Deletado com sucesso!")
                }
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
