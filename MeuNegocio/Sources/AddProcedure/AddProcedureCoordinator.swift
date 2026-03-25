//
//  AddProcedureCoordinator.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 26/08/22.
//

import Foundation
import UIKit

class AddProcedureCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = AddProcedureViewModel(coordinator: self)
        let controller = AddProcedureViewController(viewModel: viewModel, coordinator: self)
        configuration.viewController = controller
        configuration.navigationController?.setNavigationBarHidden(false, animated: true)
        configuration.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToHome() {
        configuration.navigationController?.dismiss(animated: true)
    }

    func rootViewController() -> UIViewController {
        let viewModel = AddProcedureViewModel(coordinator: self)
        let controller = AddProcedureViewController(viewModel: viewModel, coordinator: self)
        return controller
    }
}


