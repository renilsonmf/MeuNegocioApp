//
//  UserOnboardingViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//

import FirebaseAuth
import FirebaseFirestore

protocol UserOnboardingViewModelProtocol {
    func createUser(userModel: CreateUserModel, completion: @escaping (Bool) -> Void)
    func navigateToHome()
}

class UserOnboardingViewModel: UserOnboardingViewModelProtocol {
    
    // MARK: - Properties
    private var coordinator: UserOnboardingCoordinator?
    private let db = Firestore.firestore()

    
    // MARK: - Init
    init(coordinator: UserOnboardingCoordinator?) {
        self.coordinator = coordinator
    }
    
    func createUser(userModel: CreateUserModel, completion: @escaping (Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("users")
            .document(uid)
            .setData([
                "name": userModel.name,
                "barbershop": userModel.barbershop,
                "city": userModel.city,
                "state": userModel.state,
                "email": userModel.email
            ]) { error in
                
                if let error = error {
                    print("Erro ao salvar usuário:", error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    // MARK: - Routes
    func navigateToHome() {
        coordinator?.navigateToHome()
    }
    
}
