//
//  UserOnboardingViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//

import Foundation
import CoreData

protocol UserOnboardingViewModelProtocol {
    func createUser(userModel: CreateUserModel, completion: @escaping (Bool) -> Void)
    func saveDataCoreData(userModel: CreateUserModel, completion: @escaping (Bool) -> Void)
    func navigateToHome()
}

class UserOnboardingViewModel: UserOnboardingViewModelProtocol {
    
    // MARK: - Properties
    private var coordinator: UserOnboardingCoordinator?
    
    // MARK: - Init
    init(coordinator: UserOnboardingCoordinator?) {
        self.coordinator = coordinator
    }
    
    func createUser(userModel: CreateUserModel, completion: @escaping (Bool) -> Void) {
        
        let createUser = MNUserDefaults.getRemoteConfig()?.addUser ?? "http://54.86.122.10:3000/profile"
        
        guard let url = URL(string: createUser) else {
            print("Error: cannot create URL")
            return
        }

        /// Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(userModel) else {
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
    
    func saveDataCoreData(userModel: CreateUserModel, completion: @escaping (Bool) -> Void) {
        let entity = NSEntityDescription.entity(forEntityName: "Profile", in: CoreDataManager.shared.managedObjectContext)!
        let objeto = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared.managedObjectContext)
        
        // Configurar os atributos do objeto
        objeto.setValue(UUID().uuidString, forKeyPath: "id")
        objeto.setValue(userModel.name, forKeyPath: "name")
        objeto.setValue(userModel.barbershop, forKeyPath: "barbershop")
        objeto.setValue(userModel.city, forKeyPath: "city")
        objeto.setValue(userModel.state, forKeyPath: "state")
        objeto.setValue(userModel.email, forKeyPath: "email")
        
        do {
            try CoreDataManager.shared.managedObjectContext.save()
            completion(true)
        } catch let error as NSError {
            print("Erro ao adicionar Produto: \(error), \(error.userInfo)")
            completion(false)
        }
    }
    
    // MARK: - Routes
    func navigateToHome() {
        coordinator?.navigateToHome()
    }
    
}
