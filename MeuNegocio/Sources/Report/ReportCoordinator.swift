//
//  ReportCoordinator.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 17/02/22.
//

import UIKit

final class ReportCoordinator: BaseCoordinator {

    func start(procedures: [GetProcedureModel]) {
        let viewModel = ReportViewModel()
        let controller = ReportViewController(viewModel: viewModel, coordinator: self, procedures: procedures)
        configuration.viewController = controller
        configuration.navigationController?.setNavigationBarHidden(false, animated: true)
        configuration.navigationController?.pushViewController(controller, animated: true)
    }

    // Para uso no TabBarCoordinator
    func rootViewController() -> UIViewController {
        let viewModel = ReportViewModel()
        let controller = ReportViewController(viewModel: viewModel, coordinator: self, procedures: [])
        return controller
    }
}
