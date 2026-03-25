//
//  MainTabBarCoordinator.swift
//  MeuNegocio
//
//  Criado por Assistant em 21/03/2026.
//

import UIKit
final class MainTabBarCoordinator: BaseCoordinator {
    
    let tabBarController = MainTabBarController()
    
    override func start() {
        
        // Home
        let homeCoordinator = HomeCoordinator(with: configuration)
        let homeVC = homeCoordinator.rootViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0
        )
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        // Adicionar
        let addCoordinator = AddProcedureCoordinator(with: configuration)
        let addVC = addCoordinator.rootViewController()
        addVC.tabBarItem = UITabBarItem(
            title: "Adicionar",
            image: UIImage(systemName: "plus"),
            tag: 1
        )
        let addNav = UINavigationController(rootViewController: addVC)
        
        // Informações
        let helpCoordinator = HelpCoordinator(with: configuration)
        let helpVC = helpCoordinator.rootViewController()
        helpVC.tabBarItem = UITabBarItem(
            title: "Informações",
            image: UIImage(systemName: "info.circle"),
            tag: 2
        )
        let helpNav = UINavigationController(rootViewController: helpVC)
        
        // Relatórios
        let reportCoordinator = ReportCoordinator(with: configuration)
        let reportVC = reportCoordinator.rootViewController()
        reportVC.tabBarItem = UITabBarItem(
            title: "Relatórios",
            image: UIImage(systemName: "chart.bar"),
            tag: 3
        )
        let reportNav = UINavigationController(rootViewController: reportVC)
        
        // Configura tabs
        tabBarController.viewControllers = [
            homeNav,
            addNav,
            helpNav,
            reportNav
        ]
        
        tabBarController.selectedIndex = 0

        configuration.viewController = tabBarController
        configuration.navigationController?.setViewControllers([tabBarController], animated: true)
    }
}
