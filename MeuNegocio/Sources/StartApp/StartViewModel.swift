//
//  StartViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 27/10/22.
//

import Foundation
import FirebaseAuth
import CoreData

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
       // if checkPassedTheOnboarding() {
       //     autoLogin()
       // } else {
       //     self.coordinator?.navigateToLogin()
       // }
        
        userDataCoreData().isEmpty ? self.coordinator?.navigateToOnboarding() : self.coordinator?.navigateToHome()
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
    
    func userDataCoreData() -> UserModelList {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")

        do {
            guard let users = try CoreDataManager.shared.managedObjectContext.fetch(request) as? [NSManagedObject] else {
                return []
            }

            let userList: UserModelList = users.map { user in
                return UserModel(
                    id: user.value(forKey: "id") as? String ?? "",
                    name: user.value(forKey: "name") as? String ?? "",
                    barbershop: user.value(forKey: "barbershop") as? String ?? "",
                    city: user.value(forKey: "city") as? String ?? "",
                    state: user.value(forKey: "state") as? String ?? "",
                    email: user.value(forKey: "email") as? String ?? "",
                    v: 0
                )
            }

            return userList
        } catch {
            return []
        }
    }
}
