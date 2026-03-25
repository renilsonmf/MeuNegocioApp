//
//  LoginCoordinator.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 02/08/22.
//

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = LoginViewModel(coordinator: self)
        let controller = LoginViewController(viewModel: viewModel, coordinator: self)
        configuration.viewController = controller
        configuration.navigationController?.navigationBar.isHidden = true
        configuration.navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToHome() {
        let coordinator = MainTabBarCoordinator(with: configuration)
        coordinator.start()
    }
    
    func navigateToUserOnboarding() {
        let coordinator = UserOnboardingCoordinator(with: configuration)
        coordinator.start()
        configuration.navigationController?.removeViewController(LoginViewController.self)
    }
    
    func navigateToForgotPassword(email: String) {
        let coordinator = ForgetPasswordCoordinator(with: configuration)
        coordinator.email = email
        coordinator.start()
    }
    
    func navigateToRegister() {
        let coordinator = CreateAccountCoordinator(with: configuration)
        coordinator.start()
    }

    func checkYourAccount() {
        let coordinator = CheckYourAccountCoordinator(with: configuration)
        coordinator.start()
    }
}

extension UINavigationController {
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.willMove(toParent: nil)
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
        }
    }
}
