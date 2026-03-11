//
//  StartViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 27/10/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol StartViewModelProtocol {
    func validate()
}

class StartViewModel: StartViewModelProtocol {
    
    // MARK: - Properties
    private var coordinator: StartCoordinator?
    
    // MARK: - Init
    init(coordinator: StartCoordinator?) {
        self.coordinator = coordinator
    }
    
    private func checkPassedTheOnboarding() -> Bool {
        let email = Auth.auth().currentUser?.email ?? .stringEmpty
        return MNUserDefaults.get(boolForKey: email) ?? false
    }
    
    func validate() {
        if checkPassedTheOnboarding() {
            autoLogin()
        } else {
            self.coordinator?.navigateToLogin()
        }
    }
    
    func autoLogin() {
        /// Checa se existe valor na chave
        let data = KeychainService.loadCredentials()
        if KeychainService.verifyIfExists() {
            guard let email = data.first else { return }
            guard let password = data.last else { return }
            
            Auth.auth().signIn(withEmail: email, password:  password) { _, error in
                if error != nil {
                    self.coordinator?.navigateToLogin()
                } else {
                    self.coordinator?.navigateToHome()
                }
            }
        } else {
            self.coordinator?.navigateToLogin()
        }
    }

    func fetchUser(completion: @escaping (UserModel?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                
                guard let data = snapshot?.data(), error == nil else {
                    completion(nil)
                    return
                }

                let user = UserModel(
                    name: data["name"] as? String ?? "",
                    barbershop: data["barbershop"] as? String ?? "",
                    city: data["city"] as? String ?? "",
                    state: data["state"] as? String ?? "",
                    email: data["email"] as? String ?? ""
                )

                completion(user)
            }
    }
}
