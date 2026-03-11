//
//  ProfileViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/08/22.
//

import UIKit
import FirebaseAuth

class ProfileViewController: CoordinatedViewController {
    
    // MARK: - Private properties
    private lazy var customView = ProfileView(
        didTapLogout: weakify { $0.logout() },
        didTapdeleteAccount: weakify { $0.deleteAccount() }
    )

    private let viewModel: ProfileViewModelProtocol
    private var userData: UserModel? = nil
    
    init(viewModel: ProfileViewModelProtocol, coordinator: CoordinatorProtocol, userData: UserModel?){
        self.viewModel = viewModel
        self.userData = userData
        super.init(coordinator: coordinator)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Perfil"
        setUserData()
    }
    
    override func loadView() {
        super.loadView()
        navigationController?.navigationBar.barTintColor = .MNColors.lightBrown
        self.view = customView
    }
    
    private func setUserData() {
        self.customView.user = userData
    }
    
    private func logout() {
        viewModel.signOut { [ weak self ] result in
            result ? self?.viewModel.logout() : self?.showAlert(
                title: "Ocorreu um erro",
                messsage: "Tente novamente mais tarde"
            )
        }
    }
    
    private func deleteAccount() {
        self.showDeleteAlert(
            title: "Essa ação é irreversível",
            messsage: "Todos os seus dados serão removidos. \nTem certeza que deseja deletar sua conta?",
            closedScreen: false
        ) {
            self.viewModel.deleteUserAccount { [ weak self ] delete in
                DispatchQueue.main.async {
                    delete ? self?.viewModel.logout() : self?.showAlert(
                        title: "Ocorreu um erro ao excluir sua conta",
                        messsage: "Tente novamente mais tarde.")
                }
            }
        }
    }

    private var authUser : User? {
        return Auth.auth().currentUser
    }

    public func sendVerificationMail() {
        if self.authUser != nil && Current.shared.isEmailVerified.not {
            self.authUser!.sendEmailVerification(completion: { (error) in
                self.showAlert(
                    title: "Atenção!",
                    messsage: "Foi enviado para seu email um link para verificar a sua conta. \nVerifique sua caixa de spam."
                )
            })
        } else { self.showAlert() }
    }
}
