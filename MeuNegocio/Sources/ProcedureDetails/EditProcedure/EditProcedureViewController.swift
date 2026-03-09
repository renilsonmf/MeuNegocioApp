//
//  EditProcedureViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 02/02/23.
//

import Foundation
import UIKit

protocol CloseAndUpdateProcedureDelegate: AnyObject {
    func updateProcedureDetails(_ procedure: GetProcedureModel)
}

final class EditProcedureViewController: CoordinatedViewController {
    
    private let customView = EditProcedureView()
    private var procedure: GetProcedureModel
    private var viewModel: ProcedureDetailViewModelProtocol
    weak var delegate: CloseAndUpdateProcedureDelegate?
    
    init(coordinator: CoordinatorProtocol, viewModel: ProcedureDetailViewModelProtocol, procedure: GetProcedureModel) {
        self.viewModel = viewModel
        self.procedure = procedure
        super.init(coordinator: coordinator)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        customView.setValues(procedure: procedure)
        customView.delegate = self
    }
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    private func closedView(_ procedure: GetProcedureModel) {
        self.delegate?.updateProcedureDetails(procedure)
        self.viewModel.closed(.present)
    }
    
}

extension EditProcedureViewController: EditProcedureDelegate {
    func alertForTextField(message: String) {
        customView.saveButton.loadingIndicator(show: false)
        showAlert(title: "", messsage: message)
    }
    
    func isSomeEmptyField(message: String) {
        customView.saveButton.loadingIndicator(show: false)
        showAlert(title: "", messsage: message)
    }
    
    func saveProcedure(procedures: GetProcedureModel) {
        self.viewModel.updateProcedure(procedures) { result, isSuccess in
            self.customView.saveButton.loadingIndicator(show: false)
            
            let valueLiquid = (Double(result.value ?? "") ?? 0) + (Double(result.costs ?? "") ?? 0)

            let model = GetProcedureModel(_id: procedures._id,
                                          nameClient: result.nameClient ?? procedures.nameClient,
                                          typeProcedure: result.typeProcedure ?? procedures.typeProcedure,
                                          formPayment: PaymentMethodType(rawValue: result.formPayment ?? "") ?? procedures.formPayment,
                                          value: result.value ?? procedures.value,
                                          currentDate: procedures.currentDate,
                                          email: procedures.email,
                                          costs: result.costs,
                                          valueLiquid: String(valueLiquid))
            if isSuccess {
                self.showAlert(title: "", messsage: "Procedimento atualizado!") {
                    self.closedView(model)
                }
            } else {
                self.showAlert(title: "Ocorreu um erro", messsage: "Tente novamente mais tarde!")
            }
        }
    }
    
    
}
