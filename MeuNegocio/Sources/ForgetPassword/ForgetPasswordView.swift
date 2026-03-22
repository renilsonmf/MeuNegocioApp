//
//  ForgetPasswordView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 04/09/22.
//

import Foundation

import UIKit

final class ForgetPasswordView: UIView {
    
    var didTapResetAction: Action?
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Code
    private lazy var gripView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: MNLabel = {
        let label = MNLabel(text: "Redefinir senha",
                                font: UIFont.boldSystemFont(ofSize: 20),
                                textColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var subTitleLabel: MNLabel = {
        let label = MNLabel(text: "Informe o e-mail cadastrado para enviarmos \n um e-mail de redefinição de senha.",
                                font: UIFont.systemFont(ofSize: 16),
                                textColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField(titlePlaceholder: "E-mail cadastrado",
                                        colorPlaceholder: .lightGray,
                                        textColor: .MNColors.darkGray,
                                        radius: 5,
                                        borderColor: UIColor.systemGray.cgColor,
                                        borderWidth: 0.5,
                                        keyboardType: .emailAddress)
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var sendButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Enviar",
                                  colorTitle: .darkGray,
                                  radius: 10,
                                  background: .systemGray)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        return button
    }()

    func isEnabledSendButton(_ isEnabled: Bool) {
        if isEnabled {
            sendButton.backgroundColor = .MNColors.yellow
            sendButton.isEnabled = true
        } else {
            sendButton.backgroundColor = .systemGray
            sendButton.isEnabled = false
        }
    }
    
    // MARK: - Action TextFields
    @objc func textFieldEditingDidChange(sender: UITextField) {
        guard let email = emailTextField.text else { return }
        let isValidEmail = email.isValidEmail()
        isValidEmail ? isEnabledSendButton(true) : isEnabledSendButton(false)
    }
    
    // MARK: - Action Buttons
    @objc
    private func didTapSend() {
        sendButton.loadingIndicator(show: true)
        self.didTapResetAction?()
    }
}

extension ForgetPasswordView: ViewCodeContract {

    func setupHierarchy() {
        addSubview(gripView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(emailTextField)
        addSubview(sendButton)
    }
    
    func setupConstraints() {
        gripView
            .topAnchor(in: self, attribute: .top, padding: 11)
            .centerX(in: self)
            .widthAnchor(32)
            .heightAnchor(4)
        
        titleLabel
            .topAnchor(in: gripView, attribute: .bottom, padding: 44)
            .centerX(in: self)
        
        subTitleLabel
            .topAnchor(in: titleLabel, attribute: .bottom, padding: 16)
            .centerX(in: self)
        
        emailTextField
            .topAnchor(in: subTitleLabel, attribute: .bottom, padding: 32)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(48)

        sendButton
            .topAnchor(in: emailTextField, attribute: .bottom, padding: 48)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(48)
    }

    func setupConfiguration() {
        backgroundColor = .white
    }
    
}
