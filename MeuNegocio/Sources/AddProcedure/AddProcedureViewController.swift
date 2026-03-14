//
//  AddProcedureViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 26/08/22.
//

import UIKit

class AddProcedureViewController: CoordinatedViewController {
    
    // MARK: - Properties
    private let customView = AddProcedureView()
    private let viewModel: AddProcedureViewModelProtocol
    
    init(viewModel: AddProcedureViewModelProtocol, coordinator: CoordinatorProtocol){
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cadastrar Procedimento"
        self.hideKeyboardWhenTappedAround()
        customView.delegateActions = self
    }
    
    override func loadView() {
        super.loadView()
        navigationController?.navigationBar.barTintColor = .white
        self.view = customView
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIViewController.findCurrentController()?.viewWillAppear(true)
    }

}

extension AddProcedureViewController: AddProcedureActionsProtocol {
    
    func addProcedure(nameClient: String, typeProcedure: String, formPayment: String, value: String, email: String, costs: String) {
        customView.addButton.loadingIndicator(show: true)
        viewModel.createProcedureFirestore(
            procedure: CreateProcedureModel(
                nameClient: nameClient,
                typeProcedure: typeProcedure,
                formPayment: formPayment,
                value: value,
                currentDate: .currentDateSystem,
                email: email,
                costs: costs)) { [ weak self ] result in
                    guard let self = self else {return}
                    if result {
                        self.customView.addButton.loadingIndicator(show: false)
                        self.showAlert(title: String.stringEmpty, messsage: "Adicionado com sucesso!") {
                            self.viewModel.closed()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Ocorreu um erro", messsage: "Tente novamente mais tarde")
                            self.customView.addButton.loadingIndicator(show: false)
                        }
                    }
                }
    }

    func alertForTextField(message: String) {
        customView.addButton.loadingIndicator(show: false)
        showAlert(title: "Atenção",
                  messsage: message)
    }
    
}
