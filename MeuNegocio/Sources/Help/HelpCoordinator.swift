//
//  HelpCoordinator.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 04/09/22.
//

import UIKit

class HelpCoordinator: BaseCoordinator {
    var title: String?

    override func start() {
        let viewModel = HelpViewModel(coordinator: self)
        let controller = HelpViewController(viewModel: viewModel, coordinator: self, titleEmail: title)
        configuration.viewController = controller
        configuration.navigationController?.setNavigationBarHidden(false, animated: true)
        configuration.navigationController?.pushViewController(controller, animated: true)
    }
    
    func closed() {
        let navigation = UINavigationController()
        navigation.setNavigationBarHidden(true, animated: false)
        self.configuration.navigationController = navigation
        let coordinator = LoginCoordinator(with: self.configuration)
        coordinator.start()
        self.configuration.keyWindow?.rootViewController = navigation
    }

    // Para uso no TabBarCoordinator
    func rootViewController() -> UIViewController {
        let viewModel = HelpViewModel(coordinator: self)
        let controller = HelpViewController(viewModel: viewModel, coordinator: self, titleEmail: title)
        return controller
    }
}
