//
//  HomeViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 31/08/22.
//

import UIKit
import CoreData

protocol HomeViewModelProtocol: AnyObject {
    func userDataCoreData() -> UserModelList
    func listProcedures() -> [GetProcedureModel]
    func navigateToReport(procedures: [GetProcedureModel])
    func navigateToProfile(_ userData: UserModelList)
    func navigateToAddProcedure()
    func navigateToHelp()
    func navigateToRateApp()
    func openProcedureDetails(_ procedure: GetProcedureModel)
    func makeTotalAmounts(_ procedures: [GetProcedureModel]) -> String
}

class HomeViewModel: HomeViewModelProtocol {
    
    private let service: HomeServiceProtocol

    // MARK: - Properties
    private var coordinator: HomeCoordinator?

    // MARK: - Init
    init(service: HomeServiceProtocol = HomeService(), coordinator: HomeCoordinator?) {
        self.coordinator = coordinator
        self.service = service
    }

    /// We set up the total value of the procedure.
    func makeTotalAmounts(_ procedures: [GetProcedureModel]) -> String {
        let proceduresAmounts: [Double] = procedures.map({ Double($0.valueLiquid ?? $0.value) ?? 00.00 })
        let values = proceduresAmounts.map({ $0.plata })
        let amount = values.map { $0 }
        let sum = amount.reduce(0, +)
        return sum.rawValue.plata.string(currency: .br)
    }
    
    func listProcedures() -> [GetProcedureModel] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AddProduct")

        do {
            let procedures = try CoreDataManager.shared.managedObjectContext.fetch(request) as! [NSManagedObject]
            
            // Mapear NSManagedObjects para GetProcedureModel
            let getProcedureModels: [GetProcedureModel] = procedures.map { procedure in
                return GetProcedureModel(
                    _id: procedure.value(forKey: "id") as? String ?? "",
                    nameClient: procedure.value(forKey: "nameClient") as? String ?? "",
                    typeProcedure: procedure.value(forKey: "typeProcedure") as? String ?? "",
                    formPayment: PaymentMethodType(rawValue: procedure.value(forKey: "formPayment") as? String ?? "") ?? .other,
                    value: procedure.value(forKey: "value") as? String ?? "",
                    currentDate: procedure.value(forKey: "currentDate") as? String ?? "",
                    email: procedure.value(forKey: "email") as? String ?? "",
                    costs: procedure.value(forKey: "costs") as? String,
                    valueLiquid: procedure.value(forKey: "valueLiquid") as? String
                )
            }

            return getProcedureModels
        } catch let error {
            print("Erro ao recuperar procedimentos: \(error.localizedDescription)")
            return []
        }
    }
    
    func userDataCoreData() -> UserModelList {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")

        do {
            let users = try CoreDataManager.shared.managedObjectContext.fetch(request) as! [NSManagedObject]

            // Mapear todos os objetos para UserModel
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
        } catch let error {
            print("Erro ao recuperar dados do usuário: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Routes
    func navigateToReport(procedures: [GetProcedureModel]) {
        TrackEvent.track(event: .homeReport)
        coordinator?.navigateTo(.Report(procedures))
    }

    func navigateToProfile(_ userData: UserModelList) {
        TrackEvent.track(event: .homeProfile)
        coordinator?.navigateTo(.Profile(userData))
    }

    func navigateToAddProcedure() {
        TrackEvent.track(event: .homeAddProcedure)
        coordinator?.navigateTo(.AddProcedure)
    }

    func navigateToHelp() {
        TrackEvent.track(event: .homeInfo)
        coordinator?.navigateTo(.Help)
    }
    
    func navigateToRateApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.coordinator?.navigateTo(.rateApp)
        })
    }

    func openProcedureDetails(_ procedure: GetProcedureModel) {
        TrackEvent.track(event: .homeProcedureDetails)
        coordinator?.navigateTo(.detailProcedure(procedure))
    }
}

