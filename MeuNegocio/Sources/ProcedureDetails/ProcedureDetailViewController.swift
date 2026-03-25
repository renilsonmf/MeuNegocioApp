//
//  ProcedureDetailViewController.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 25/09/22.
//

import Foundation
import UIKit

final class ProcedureDetailViewController: CoordinatedViewController {
    
    // MARK: - Properties
    private let viewModel: ProcedureDetailViewModelProtocol
    private var procedure: GetProcedureModel

    // MARK: - View
    private lazy var customView = ProcedureDetailView(
        didTapDelete: weakify { $0.deleteProcedure(procedure: $1) },
        didTapEditProcedure: { self.editProcedure(procedure: $0)}
    )

    // MARK: - Init
    init(viewModel: ProcedureDetailViewModelProtocol, coordinator: CoordinatorProtocol, procedure: GetProcedureModel) {
        self.viewModel = viewModel
        self.procedure = procedure
        super.init(coordinator: coordinator)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalhes"
        customView.setupView(procedure: procedure)
        self.hideKeyboardWhenTappedAround()
        viewModel.coordinator?.delegate = self
    }

    override func loadView() {
        super.loadView()
        view = customView
    }

    private func editProcedure(procedure: GetProcedureModel) {
        viewModel.goToEditProcedure(procedure)
    }

    private func deleteProcedure(procedure: String) {
        self.showDeleteAlert(closedScreen: true) {
            self.viewModel.deleteProcedure(procedure) { message in
                DispatchQueue.main.async {
                    self.showAlert(title: "", messsage: message) {
                        TrackEvent.track(event: .homeDeleteProcedure)
                        return self.closedView()
                    }
                }
            }
        }
    }

    private func closedView() {
        self.customView.deleteButton.loadingIndicator(show: false)
        viewModel.closed(.push)
    }
    
    private func reloadStackDetails() {
        self.customView.detailsStack.loadingIndicatorView(show: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.customView.detailsStack.loadingIndicatorView(show: false)
        })
    }
    
}

extension ProcedureDetailViewController: CloseAndUpdateProcedureDelegate {
    func updateProcedureDetails(_ procedure: GetProcedureModel) {
        self.customView.setupView(procedure: procedure)
        self.reloadStackDetails()
    }
}
