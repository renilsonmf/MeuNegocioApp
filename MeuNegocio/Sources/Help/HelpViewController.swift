//
//  HelpViewController.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 04/09/22.
//

import UIKit
import MessageUI

class HelpViewController: CoordinatedViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Private properties
    private var titleEmail: String?

    private lazy var customView = HelpView(
        openMailCompose: weakify { $0.openMailCompose() },
        openWhatsapp: weakify { $0.viewModel.openWhatsapp() },
        titleEmail: titleEmail ?? "Tire sua dúvida por e-mail"
    )
    
    private let viewModel: HelpViewModelProtocol

    func openMailCompose() {
        let mailComposeController = MFMailComposeViewController() .. {
            $0.mailComposeDelegate = self
            $0.setToRecipients(["innovatestechsc@gmail.com"])
            $0.setSubject(titleEmail ?? "Tenho uma dúvida")
            $0.setMessageBody("", isHTML: false)
            $0.modalPresentationStyle = .pageSheet
            $0.mailComposeDelegate = self
        }
        DispatchQueue.main.async {
            self.present(mailComposeController, animated: true)
        }
    }

    // MARK: - Init
    init(viewModel: HelpViewModelProtocol, coordinator: CoordinatorProtocol, titleEmail: String?) {
        self.titleEmail = titleEmail
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleEmail == nil ? "Informações" : "Reclamação"
    }

    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    // MARK: - MFMailComposeViewController Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        /// You should switch the result only after dismissing the controller
        controller.dismiss(animated: true) {
            let message: String
            switch result {
            case .sent: message = "Mensagem enviada com sucesso!"
            case .saved: message = "Mensagem salva!"
            case .cancelled: message = "Mensagem cancelada!"
            case .failed:  message = "Erro desconhecido!"
            @unknown default: fatalError()
            }
            self.showAlert(title: "E-mail", messsage: message)
        }
    }

}
