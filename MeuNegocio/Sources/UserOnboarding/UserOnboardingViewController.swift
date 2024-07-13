//
//  UserOnboardingViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//

import UIKit
import FirebaseAuth

class UserOnboardingViewController: CoordinatedViewController {

    // MARK: - Properties
    private let customView = UserOnboardingView()
    private let viewModel: UserOnboardingViewModelProtocol

    init(viewModel: UserOnboardingViewModelProtocol, coordinator: CoordinatorProtocol){
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }

}

extension UserOnboardingViewController: CreateUserOnboardingProtocol {
    func addUserOnboarding(model: CreateUserModel) {
        customView.continueButton.loadingIndicator(show: true)
        viewModel.saveDataCoreData(userModel: CreateUserModel(
            name: model.name,
            barbershop: model.barbershop,
            city: model.city,
            state: model.state,
            email: model.email)) { [weak self] onSuccess in
                if onSuccess {
                    self?.viewModel.navigateToHome()
                    let email = Auth.auth().currentUser?.email ?? ""
                    MNUserDefaults.set(value: true, forKey: email)
                } else {
                    self?.showAlert(title: "Ocorreu um erro", messsage: "Tente novamente.")
                }
                self?.customView.continueButton.loadingIndicator(show: true)
            }
    }
    
    func alertEmptyField() {
        customView.continueButton.loadingIndicator(show: false)
        showAlert(title: "Atenção",
                  messsage: "Preencha todos os campos.")
    }
    
    
}
