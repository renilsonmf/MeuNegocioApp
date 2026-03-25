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
        let nav = UINavigationController(rootViewController: controller)
        configuration.navigationController?.present(nav, animated: true)
    }
    
    func closed() {
        configuration.navigationController?.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let navigation = UINavigationController()
            navigation.setNavigationBarHidden(true, animated: false)
            self.configuration.navigationController = navigation
            let coordinator = LoginCoordinator(with: self.configuration)
            coordinator.start()
            self.configuration.keyWindow?.rootViewController = navigation
        }
    }
}
