//
//  ProfileCoordinator.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/08/22.
//

import UIKit

class ProfileCoordinator: BaseCoordinator {
    func start(userData: UserModel?) {
        let viewModel = ProfileViewModel(coordinator: self)
        let controller = ProfileViewController(viewModel: viewModel, coordinator: self, userData: userData)
        configuration.viewController = controller
        configuration.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        configuration.navigationController?.navigationBar.tintColor = .MNColors.darkGray
        configuration.navigationController?.present(controller, animated: true)
    }
    
    func closed() {
        let coordinator = LoginCoordinator(with: configuration)
        configuration.navigationController?.dismiss(animated: true)
        configuration.navigationController?.viewControllers.removeAll()
        coordinator.start()
    }
}
