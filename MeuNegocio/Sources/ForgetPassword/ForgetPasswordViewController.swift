//
//  ForgetPasswordViewController.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 04/09/22.
//

import UIKit

class ForgetPasswordViewController: CoordinatedViewController {
    
    // MARK: - Private properties
    private lazy var customView = ForgetPasswordView()

    private let viewModel: ForgetPasswordViewModelProtocol?
    
    // MARK: - Init
    init(viewModel: ForgetPasswordViewModelProtocol, coordinator: CoordinatorProtocol, email: String) {
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
        customView.emailTextField.text = email
        customView.isEnabledSendButton(email.isEmpty.not)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Redefinir senha"
        submitPassword()
        self.hideKeyboardWhenTappedAround()
    }

    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    private func submitPassword() {
        customView.didTapResetAction = {
            guard let email = self.customView.emailTextField.text else { return }
            self.viewModel?.resetPassFirebase(email: email,
                                              completion: { [ weak self ] onSuccess, typeError  in
                onSuccess ? self?.isEmailWasSent(true) : self?.isEmailWasSent(false, typeError)
                self?.customView.sendButton.loadingIndicator(show: false)
            })
        }
    }
    
    private func isEmailWasSent( _ result: Bool, _ error: String = .stringEmpty) {
        if result {
            showAlert(title: "Atenção",
                      messsage: "Foi enviado um link para redefinir a sua senha no email cadastrado. \nVerifique sua caixa de spam.",
                      completion: { self.dismiss(animated: true) })
        } else {
            showAlert(title: "Ops!", messsage: error)
        }
    }

}
