//
//  ProcedureDetailService.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/01/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol ProcedureDetailServiceProtocol {
    func deleteProcedureFirestore(_ procedure: String, completion: @escaping (String) -> Void)
    func updateProcedureFirestore(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void)
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
    
    func updateProcedureFirestore(procedure: GetProcedureModel, completion: @escaping (UpdatedProceduresModel, Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(UpdatedProceduresModel(), false)
            return
        }
        
        firestore.collection("users")
            .document(uid)
            .collection("procedures")
            .document(procedure._id)
            .updateData([
                "nameClient": procedure.nameClient,
                "typeProcedure": procedure.typeProcedure,
                "formPayment": procedure.formPayment.rawValue,
                "value": procedure.value,
                "costs": procedure.costs.orEmpty
            ]) { error in
                if let error = error {
                    print("Erro ao atualizar:", error)
                    completion(UpdatedProceduresModel(), false)
                } else {
                    let updatedModel = UpdatedProceduresModel(
                        nameClient: procedure.nameClient,
                        typeProcedure: procedure.typeProcedure,
                        formPayment: procedure.formPayment.rawValue,
                        value: procedure.value,
                        costs: procedure.costs.orEmpty
                    )
                    completion(updatedModel, true)
                }
            }
    }
}
