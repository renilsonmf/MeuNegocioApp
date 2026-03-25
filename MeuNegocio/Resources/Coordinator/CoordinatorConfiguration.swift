//
//  CoordinatorConfiguration.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 07/02/22.
//

import UIKit

public class CoordinatorConfiguration {
    
    public weak var window: UIWindow?
    public weak var navigationController: UINavigationController?
    public weak var viewController: UIViewController?
    public weak var view: UIView?

    /// Retorna o rootViewController da window de forma confiável.
    public var rootPresenter: UIViewController? {
        if let root = window?.rootViewController {
            return root
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    /// Retorna a key window de forma confiável.
    public var keyWindow: UIWindow? {
        return window ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    public init(window: UIWindow? = nil,
                viewController: UIViewController? = nil,
                navigationController: UINavigationController? = nil,
                view: UIView? = nil) {
        self.window = window
        self.navigationController = navigationController
        self.viewController = viewController
        self.view = view
    }
}
