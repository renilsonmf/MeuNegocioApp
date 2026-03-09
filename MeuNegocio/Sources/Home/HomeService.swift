//
//  HomeService.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//
import Foundation
import FirebaseAuth
import CoreData

protocol HomeServiceProtocol {
    func getProcedureList(completion: @escaping ([GetProcedureModel]) -> Void)
    func deleteProcedure(_ procedure: String, completion: @escaping () -> Void)
    func fetchUser(completion: @escaping (UserModelList) -> Void)
    
    func getProcedureListCoreData(completion: @escaping ([GetProcedureModel]) -> Void)
    func fetchUserCoreData(completion: @escaping (UserModelList) -> Void)
}

class HomeService: HomeServiceProtocol {

    // Get procedure list
    func getProcedureList(completion: @escaping ([GetProcedureModel]) -> Void) {
        guard let email = Auth.auth().currentUser?.email else { return }

        let urlProcedureList = MNUserDefaults.getRemoteConfig()?.getProcedureByEmail ?? "http://54.86.122.10:3000/procedure/"
        
        let urlString = "\(urlProcedureList)\(email)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode([GetProcedureModel].self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            catch {
                let error = error
                print(error)
            }
        }.resume()
    }

    // Delete procedure
    func deleteProcedure(_ procedure: String, completion: @escaping () -> Void) {
        
        let deleteProcedureById = MNUserDefaults.getRemoteConfig()?.deleteProcedureById ?? "http://54.86.122.10:3000/procedure/"
        
        let urlString = "\(deleteProcedureById)\(procedure)"
        
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlReq) { _, _, _ in
            completion()
        }.resume()
    }
    
    func fetchUser(completion: @escaping (UserModelList) -> Void) {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let getUserByEmail = MNUserDefaults.getRemoteConfig()?.getUserByEmail ?? "http://54.86.122.10:3000/profile/"
        
        let urlString = "\(getUserByEmail)\(email)"

        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(UserModelList.self, from: data)
                completion(result)
            }
            catch {
                let error = error
                print(error)
            }
        }.resume()
    }
}

// MARK: Metodos para coletar dados do CoreData
extension HomeService {
    func getProcedureListCoreData(completion: @escaping ([GetProcedureModel]) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AddProduct")

        do {
            guard let procedures = try CoreDataManager.shared.managedObjectContext.fetch(request) as? [NSManagedObject] else {
                completion([])
                return
            }
            
            let getProcedureModels: [GetProcedureModel] = procedures.map { procedure in
                let value = procedure.value(forKey: "value") as? String ?? ""
                let costs = procedure.value(forKey: "costs") as? String ?? ""
                let valueLiquid = (Double(value) ?? 0) - (Double(costs) ?? 0)
                
                return GetProcedureModel(
                    _id: procedure.value(forKey: "id") as? String ?? "",
                    nameClient: procedure.value(forKey: "nameClient") as? String ?? "",
                    typeProcedure: procedure.value(forKey: "typeProcedure") as? String ?? "",
                    formPayment: PaymentMethodType(rawValue: procedure.value(forKey: "formPayment") as? String ?? "") ?? .other,
                    value: procedure.value(forKey: "value") as? String ?? "",
                    currentDate: procedure.value(forKey: "currentDate") as? String ?? "",
                    email: procedure.value(forKey: "email") as? String ?? "",
                    costs: procedure.value(forKey: "costs") as? String,
                    valueLiquid: String(valueLiquid)
                )
            }

            completion(getProcedureModels)
        } catch {
            completion([])
        }
    }
    
    func fetchUserCoreData(completion: @escaping (UserModelList) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")

        do {
            guard let users = try CoreDataManager.shared.managedObjectContext.fetch(request) as? [NSManagedObject] else {
                completion(UserModelList())
                return
            }

            // Mapear todos os objetos para UserModel
            let result: UserModelList = users.map { user in
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

            completion(result)
        } catch {
            completion(UserModelList())
        }
    }
}
