//
//  HomeService.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//
import FirebaseAuth
import FirebaseFirestore

protocol HomeServiceProtocol {
    func deleteProcedure(_ procedure: String, completion: @escaping () -> Void)
    func fetchUserFirestore(completion: @escaping (UserModel?) -> Void)
    func getProcedureListFirestore(completion: @escaping ([GetProcedureModel]) -> Void)
}

class HomeService: HomeServiceProtocol {
    
    private let firesore = Firestore.firestore()

    func fetchUserFirestore(completion: @escaping (UserModel?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        firesore.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    let data = snapshot.data() ?? [:]
                    let user = UserModel(
                        name: data["name"] as? String ?? "",
                        barbershop: data["barbershop"] as? String ?? "",
                        city: data["city"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        email: data["email"] as? String ?? ""
                    )
                    completion(user)
                } else {
                    completion(nil)
                }
            }
    }
    
    func getProcedureListFirestore(completion: @escaping ([GetProcedureModel]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        firesore.collection("users")
            .document(uid)
            .collection("procedures")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let procedures: [GetProcedureModel] = documents.map { doc in
                    
                    let data = doc.data()
                    let value = data["value"] as? String ?? ""
                    let costs = data["costs"] as? String ?? ""
                    let valueLiquid = (Double(value) ?? 0) - (Double(costs) ?? 0)
                    
                    return GetProcedureModel(
                        _id: data["id"] as? String ?? "",
                        nameClient: data["nameClient"] as? String ?? "",
                        typeProcedure: data["typeProcedure"] as? String ?? "",
                        formPayment: PaymentMethodType(
                            rawValue: data["formPayment"] as? String ?? ""
                        ) ?? .other,
                        value: value,
                        currentDate: data["currentDate"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        costs: costs,
                        valueLiquid: String(valueLiquid)
                    )
                }
                completion(procedures)
            }
    }
    
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
}
