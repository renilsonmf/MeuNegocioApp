//
//  CheckYourAccountView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 06/10/22.
//

import UIKit

class CheckYourAccountView: UIView, ViewCodeContract {

    var didTapVerifiedButton: Action
    
    init(didTapVerifiedButton: @escaping Action) {
        self.didTapVerifiedButton = didTapVerifiedButton
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var gripView = UIView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lightGray
        $0.roundCorners(cornerRadius: 2)
    }

    private lazy var emptyView: ErrorView = {
        let view = ErrorView(title: "Verifique seu e-mail!",
                             subTitle: "Foi enviado para seu email um link de verificação. Caso não tenha recebido clique em verificar conta para enviarmos um novo email ou verifique sua caixa de spam.",
                             imageName: "icon-alert-error")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var verifiedEmailButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Verificar conta",
                                  colorTitle: .darkGray,
                                  radius: 10,
                                  background: .MNColors.yellow)
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    func setupHierarchy() {
        addSubview(gripView)
        addSubview(emptyView)
        emptyView.addSubview(verifiedEmailButton)
    
    }
    
    func setupConstraints() {
        
        gripView
            .topAnchor(in: self, padding: 10)
            .centerX(in: self)
            .heightAnchor(4)
            .widthAnchor(35)

        emptyView
            .topAnchor(in: self, attribute: .top, padding: 150)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self)
        
        verifiedEmailButton
            .leftAnchor(in: emptyView, padding: 20)
            .rightAnchor(in: emptyView, padding: 20)
            .bottomAnchor(in: emptyView, padding: 40)
            .heightAnchor(48)
    }

    @objc
    func handleLoginButton() {
        verifiedEmailButton.loadingIndicator(show: true)
        didTapVerifiedButton()
    }

    func setupConfiguration() {
        self.backgroundColor = .white
    }
    
}
 
