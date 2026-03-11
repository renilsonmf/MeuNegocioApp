//
//  HomeViewModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 31/08/22.
//

import UIKit

protocol HomeViewModelProtocol: AnyObject {
    var input: HomeViewModelInputProtocol { get }
    var output: HomeViewModelOutputProtocol { get }
    func navigateToReport(procedures: [GetProcedureModel])
    func navigateToProfile(_ userData: UserModel?)
    func navigateToAddProcedure()
    func navigateToHelp()
    func navigateToRateApp()
    func openProcedureDetails(_ procedure: GetProcedureModel)
    func makeTotalAmount(_ procedures: [GetProcedureModel]) -> String
}

// MARK: - Protocols
protocol HomeViewModelOutputProtocol {
    var procedures: Bindable<[GetProcedureModel]> { get }
    var userData: Bindable<UserModel?> { get }
}

protocol HomeViewModelInputProtocol {
    func loadHome()
    func makeTotalAmounts(_ procedures: [GetProcedureModel]) -> String
}

class HomeViewModel: HomeViewModelProtocol, HomeViewModelOutputProtocol {

    private let service: HomeServiceProtocol

    var input: HomeViewModelInputProtocol { self }
    var output: HomeViewModelOutputProtocol { self }
    var procedures: Bindable<[GetProcedureModel]> = .init([])
    var userData: Bindable<UserModel?> = .init(nil)

    // MARK: - Properties
    private var coordinator: HomeCoordinator?

    // MARK: - Init
    init(service: HomeServiceProtocol = HomeService(), coordinator: HomeCoordinator?) {
        self.coordinator = coordinator
        self.service = service
    }

    private func fetchProcedureItems() {
        service.getProcedureListCoreData { result in
            DispatchQueue.main.async {
                self.procedures.value = result
            }
        }
    }
    
    private func fetchUserData() {
        service.fetchUser { result in
            DispatchQueue.main.async {
                self.userData.value = result
            }
        }
    }

    /// We set up the total value of the procedure.
    func makeTotalAmount(_ procedures: [GetProcedureModel]) -> String {
        let proceduresAmounts: [Double] = procedures.map({ Double($0.valueLiquid ?? $0.value) ?? 00.00 })
        let values = proceduresAmounts.map({ $0.plata })
        let amount = values.map { $0 }
        let sum = amount.reduce(0, +)
        return sum.rawValue.plata.string(currency: .br)
    }

    // MARK: - Routes
    func navigateToReport(procedures: [GetProcedureModel]) {
        TrackEvent.track(event: .homeReport)
        coordinator?.navigateTo(.Report(procedures))
    }

    func navigateToProfile(_ userData: UserModel?) {
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

extension HomeViewModel: HomeViewModelInputProtocol {
    func loadHome() {
        fetchProcedureItems()
        fetchUserData()
    }

    func makeTotalAmounts(_ procedures: [GetProcedureModel]) -> String {
        makeTotalAmount(procedures)
    }
}
