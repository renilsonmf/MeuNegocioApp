//
//  AddProcedureViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/08/22.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

protocol AddProcedureViewModelProtocol {
    func createProcedure(procedure: CreateProcedureModel, completion: @escaping (Bool) -> Void)
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
