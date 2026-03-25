//
//  RateAppCoordinator.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 19/12/22.
//

import UIKit
import SafariServices

class RateAppCoordinator: BaseCoordinator {

    func start(navigation: UINavigationController) {
        let viewModel = RateAppViewModel(coordinator: self)
        let controller = RateAppViewController(
            coordinator: self,
            viewModel: viewModel,
            navigation: navigation
        )
        controller.modalPresentationStyle = .custom
        controller.modalTransitionStyle = .crossDissolve
        configuration.navigationController?.present(controller, animated: false, completion: nil)
    }
    
    func close() {
        configuration.navigationController?.dismiss(animated: true)
    }
    
    func goToReview() {
        configuration.navigationController?.dismiss(animated: true, completion: {
            if let url = URL(string: "https://itunes.apple.com/app/id6443727568") {
                UIApplication.shared.open(url)
            }
        })
    }

    func goToHelp() {
        let coordinator = HelpCoordinator(with: configuration)
        coordinator.title = "Enviar reclamação"
        coordinator.start()
    }
}
