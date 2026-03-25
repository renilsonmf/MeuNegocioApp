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
        // Home — precisa de nav para push (Profile, Details, Report, Help)
        let homeNav = UINavigationController()
        homeNav.setNavigationBarHidden(true, animated: false)
        let homeConfig = CoordinatorConfiguration(window: configuration.window, navigationController: homeNav)
        let homeCoordinator = HomeCoordinator(with: homeConfig)
        let homeVC = homeCoordinator.rootViewController()
        homeNav.viewControllers = [homeVC]
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        // Adicionar — sem nav (não faz push em nenhuma tela)
        let addConfig = CoordinatorConfiguration(window: configuration.window)
        let addCoordinator = AddProcedureCoordinator(with: addConfig)
        let addVC = addCoordinator.rootViewController()
        addVC.tabBarItem = UITabBarItem(title: "Adicionar", image: UIImage(systemName: "plus"), tag: 1)

        // Informações — sem nav
        let helpConfig = CoordinatorConfiguration(window: configuration.window)
        let helpCoordinator = HelpCoordinator(with: helpConfig)
        let helpVC = helpCoordinator.rootViewController()
        helpVC.tabBarItem = UITabBarItem(title: "Informações", image: UIImage(systemName: "info.circle"), tag: 2)

        // Relatórios — sem nav
        let reportConfig = CoordinatorConfiguration(window: configuration.window)
        let reportCoordinator = ReportCoordinator(with: reportConfig)
        let reportVC = reportCoordinator.rootViewController()
        reportVC.tabBarItem = UITabBarItem(title: "Relatórios", image: UIImage(systemName: "chart.bar"), tag: 3)

        tabBarController.viewControllers = [homeNav, addVC, helpVC, reportVC]
        tabBarController.selectedIndex = 0

        configuration.viewController = tabBarController
        configuration.keyWindow?.rootViewController = tabBarController
    }
}
