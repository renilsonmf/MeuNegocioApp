//
//  CreateAccountViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 15/08/22.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: CoordinatedViewController {
    
    private var customView: CreateAccountView?
    private let viewModel: CreateAccountViewModelProtocol

    init(viewModel: CreateAccountViewModelProtocol, coordinator: CoordinatorProtocol){
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccount()
        self.hideKeyboardWhenTappedAround()
    }
    
    
    override func loadView() {
        super.loadView()
        customView = CreateAccountView()
        self.view = customView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIViewController.findCurrentController()?.viewWillAppear(true)
    }
    
    private func createAccount() {
        customView?.createAccount = weakify { weakSelf, email, password in
            weakSelf.viewModel.createAccount(email, password, resultCreateUser: { result, descriptionError  in
                weakSelf.customView?.createAccountButton.loadingIndicator(show: false)
                if result {
                    MNUserDefaults.set(value: email, forKey: MNKeys.emailNewUser)
                    weakSelf.accountCreatedSuccessfully()
                } else {
                    weakSelf.showAlert(title: "Atenção", messsage: descriptionError)
                }
            })
        }
        customView?.closedView = weakify { $0.viewModel.closed()}
    }
    
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    
    private func accountCreatedSuccessfully() {
        if self.authUser != nil && Current.shared.isEmailVerified.not {
            self.authUser!.sendEmailVerification() { (error) in
                self.showAlert(title: "Parabéns!",
                               messsage: "Conta criada com sucesso. \nFoi enviado para seu email um link de verificação. Após verificar, retorne ao app para efetuar o login. \nVerifique sua caixa de spam.") {
                    self.viewModel.closed()
                }
            }
        }
    }

    
}
