//
//  AddProcedureViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/08/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol AddProcedureViewModelProtocol {
    func createProcedureFirestore(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void)
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
    func createProcedureFirestore(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        
        let procedureId = UUID().uuidString
        
        db.collection("users")
            .document(uid)
            .collection("procedures")
            .document(procedureId)
            .setData([
                "id": procedureId,
                "value": procedure.value,
                "nameClient": procedure.nameClient,
                "formPayment": procedure.formPayment,
                "email": procedure.email,
                "typeProcedure": procedure.typeProcedure,
                "currentDate": procedure.currentDate,
                "costs": procedure.costs,
                "createdAt": Timestamp()
            ]) { error in
                
                if let error = error {
                    print("Erro ao salvar procedimento:", error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
}
