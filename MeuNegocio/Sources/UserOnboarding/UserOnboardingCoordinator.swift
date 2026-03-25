//
//  UserOnboardingCoordinator.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//

import UIKit

final class UserOnboardingCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = UserOnboardingViewModel(coordinator: self)
        let controller = UserOnboardingViewController(viewModel: viewModel, coordinator: self)
        controller.modalTransitionStyle = .crossDissolve
        configuration.viewController = controller
        configuration.navigationController?.navigationBar.isHidden = true
        configuration.navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToMainTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(with: configuration)
        mainTabBarCoordinator.start()
        configuration.navigationController?.removeViewController(UserOnboardingViewController.self)
    }
}
