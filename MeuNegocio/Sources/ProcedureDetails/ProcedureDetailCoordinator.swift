//
//  ProcedureDetailCoordinator.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 25/09/22.
//

import UIKit

enum Presentation {
    case push
    case present
}

class ProcedureDetailCoordinator: BaseCoordinator {
    
    public var procedure: GetProcedureModel? = nil
    public var delegate: CloseAndUpdateProcedureDelegate?
    
    override func start() {
        guard let procedure = procedure else { return }
        let viewModel = ProcedureDetailViewModel(coordinator: self)
        let controller = ProcedureDetailViewController(viewModel: viewModel, coordinator: self, procedure: procedure)
        configuration.viewController = controller
        configuration.navigationController?.setNavigationBarHidden(false, animated: true)
        configuration.navigationController?.pushViewController(controller, animated: true)
    }
    
    func routeEditProcedure(_ procedure: GetProcedureModel) {
        let viewModel = ProcedureDetailViewModel(coordinator: self)
        let controller = EditProcedureViewController(coordinator: self, viewModel: viewModel, procedure: procedure)
        controller.delegate = delegate
        configuration.navigationController?.present(controller, animated: true)
    }
    
    func closed(_ type: Presentation) {
        switch type {
        case .present:
            configuration.navigationController?.dismiss(animated: true)
        case .push:
            configuration.navigationController?.popViewController(animated: true)
        }
    }
}
