//
//  UIViewController+Extensions.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 24/08/22.
//

import UIKit

extension UIViewController {
    func showAlert(
        title: String = "Funcionalidade não disponível!",
        messsage: String = "Estamos trabalhando nisso.",
        completion: @escaping () -> Void? = { nil }
    ) {
        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .default) { _ in completion() }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showDeleteAlert(
        title: String = "Atenção!",
        messsage: String = "Deseja deletar este procedimento? \nEsta ação é irreversível.",
        closedScreen: Bool = false,
        completion: @escaping () -> Void? = { nil }
    ) {
        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            if closedScreen {
                self.dismiss(animated: true)
            }
        }
        let confirm = UIAlertAction(title: "Deletar", style: .default) { _ in completion() }
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
}

public extension UIViewController {

    static func findCurrentController(file: String = #file, line: Int = #line) -> UIViewController? {
        let window = UIWindow.keyWindow
        let controller = findCurrentController(base: window?.rootViewController)

        if controller == nil {
//            log.error("Unable to find current controller: \(file):\(line)")
        }

        return controller
    }

    static func findCurrentController(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return findCurrentController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return findCurrentController(base: selected)
        } else if let presented = base?.presentedViewController {
            return findCurrentController(base: presented)
        }

        return base
    }

}

extension UIWindow {
    public static var keyWindow: UIWindow? {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}

extension UIViewController {

    /// We apply it to the viewDidLoad that receives a bottomSheet, so that when we click outside the bottomsheet, it is dismissed.
    public func tappedOutViewBottomSheetDismiss() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func handleDismiss() {
        self.dismiss(animated: true)
    }
}
